# It's not possible to perfectly parse the output of 'adb shell content query --uri content://*'
# since the format is ambiguous.
# We do our best to make it work in most cases, but it's not guaranteed.
function Get-AdbContentEntry {

    # TODO(maybe): It seems that in all cases the Uri starts with 'content://',
    # if this is the case, we can remove this part from the Uri in all *-AdbContentEntry functions.

    [OutputType([PSCustomObject[]])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [string[]] $ColumnName,

        [string] $Where,

        [scriptblock] $SortBy
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    if ($ColumnName) {
        foreach ($column in $ColumnName) {
            if ($column.Contains(' ')) {
                Write-Error "Columns can't contain spaces. Column: '$_'" -ErrorAction Stop
            }
        }
        $projectionArg = " --projection $(ConvertTo-ValidAdbStringArgument ($ColumnName -join ':'))"
    }
    if ($Where) {
        $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"
    }
    if ($SortBy) {
        $sortArg = ($SortBy.Invoke() | ForEach-Object {
                Assert-ValidSortBy $_
                $_.ToAdbArgument()
            }
        ) -join ''
    }

    $lineGroupList = New-Object System.Collections.Generic.List[string]
    $lastRowIndex = 0

    InvokeAdbExpressionInternal -SerialNumber $SerialNumber -Command "shell content query --uri '$Uri'$userArg$projectionArg$whereArg$sortArg" -Verbose:$VerbosePreference `
    | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notlike '*No result found.*' } `
    | ForEach-Object {
        # Sometimes a row is split into multiple lines because a value contains a new line character.
        # We need to group these lines together to parse the row correctly.

        $isEnd = [System.Object]::ReferenceEquals($_, $script:EndObject)
        if ($isEnd) {
            if ($lineGroupList.Count -ne 0) {
                Write-Output ($lineGroupList -join "`n")
                $lineGroupList.Clear()
            }
            $lineGroupList.Clear()
            $lastRowIndex++
            Write-Output $script:EndObject
        }
        else {
            if ($lineGroupList.Count -ne 0 -and $_.StartsWith("Row: $($lastRowIndex + 1) ")) {
                Write-Output ($lineGroupList -join "`n")
                $lineGroupList.Clear()

                $lastRowIndex++
            }
            $lineGroupList.Add($_)
        }
    } `
    | Select-Object -SkipLast 1 `
    | ForEach-Object {
        $output = [PSCustomObject] @{
            RowIndex   = $lastRowIndex - 1
            RawContent = $_
        }

        $output | Add-Member -MemberType ScriptProperty -Name 'Properties' -Value {
            $rawData = $this.RawContent
            $data = [ordered] @{}
            $tokenSb = [System.Text.StringBuilder]::new()
            $charIndex = 0

            $charIndex += 'Row: '.Length
            while ($rawData[$charIndex] -ge '0' -and $rawData[$charIndex] -le '9') {
                $charIndex++
            }

            $lastKey = $null
            $flag = 'key'
            while ($true) {
                $charIndex++

                if ($charIndex -eq $rawData.Length) {
                    $data.$lastKey = $tokenSb.ToString()
                    $tokenSb.Clear() > $null
                    $flag = $null
                    $lastKey = $null
                    break
                }

                $currentChar = $rawData[$charIndex]

                switch ($flag) {
                    'key' {
                        if ($currentChar -ne '=') {
                            $tokenSb.Append($currentChar) > $null
                        }
                        else {
                            $flag = 'value'
                            $lastKey = $tokenSb.ToString().Trim()
                            $tokenSb.Clear() > $null
                        }
                    }
                    'value' {
                        $nextChar = $rawData[$charIndex + 1]
                        $nextNextChar = $rawData[$charIndex + 2]

                        if ($currentChar -eq ',' -and $nextChar -eq ' ' -and (($nextNextChar -ge 'a') -and ($nextNextChar -le 'z') -or $nextNextChar -eq '_' )) {
                            $tempIndex = $charIndex + 2
                            while ($rawData[$tempIndex] -ne '=' -and $rawData[$tempIndex] -ne ' ' -and $tempIndex -ne ($rawData.Length - 1)) {
                                $tempIndex++
                            }

                            if ($rawData[$tempIndex] -eq '=') {
                                $data.$lastKey = $tokenSb.ToString()
                                $flag = 'key'
                                $tokenSb.Clear() > $null
                                $lastKey = $null
                            }
                        }
                        else {
                            $tokenSb.Append($currentChar) > $null
                        }
                    }
                }
            }

            if ($data.Keys) {
                [PSCustomObject] $data
            }
            else {
                $null
            }
        }

        $output
    }
}



function InvokeAdbExpressionInternal {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Command
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command $Command -Verbose:$VerbosePreference

    Write-Output $script:EndObject
}



# Used to check if the current line is the last line of a row
$script:EndObject = @{}



# Examples of content URIs:
# - content://contacts/people
# - content://contacts/phones
# - content://com.android.contacts/contacts
# - content://com.android.contacts/raw_contacts
# - content://com.android.contacts/data
# - content://com.android.contacts/data/emails
# - content://com.android.contacts/groups
# - content://media/external/images/media
# - content://media/external/video/media
# - content://media/external/audio/media
# - content://media/external/downloads
# - content://media/external/audio/artists
# - content://media/external/audio/albums
# - content://media/external/audio/playlists
# - content://com.android.calendar/events
# - content://com.android.calendar/calendars
# - content://com.android.calendar/reminders
# - content://sms/inbox
# - content://sms/sent
# - content://sms/draft
# - content://sms/conversations
# - content://mms/inbox
# - content://settings/global
# - content://settings/secure
# - content://settings/system
