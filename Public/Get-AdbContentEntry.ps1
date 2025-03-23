# It's not possible to perfectly parse the output of 'adb shell content query --uri content://*'
# since the format is ambiguous.
# We do our best to make it work in most cases, but it's not guaranteed.
function Get-AdbContentEntry {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Alias('Projection')]
        [string[]] $ColumnName,

        [string] $Where

        # TODO: I tried some examples but this doesn't seem to make a difference, I might check it later
        # [string] $SortBy
    )

    begin {
        if ($ColumnName) {
            $projectionArg = " --projection $(ConvertTo-ValidAdbStringArgument ($ColumnName -join ':'))"
        }
        if ($Where) {
            $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"
        }
        # if ($SortBy) {
        #     $sortArg = " --sort $(ConvertTo-ValidAdbStringArgument $SortBy)"
        # }
    }

    process {
        foreach ($id in $DeviceId) {
            $lineGroupList = New-Object System.Collections.Generic.List[string]

            $lastRowIndex = 0

            InvokeAdbExpressionInternal -DeviceId $id -Command "shell content query --uri '$Uri'$projectionArg$whereArg" -Verbose:$VerbosePreference `
            | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notlike '*No result found.*' } `
            | ForEach-Object {
                # Sometimes a row is split into multiple lines, so we group them together

                $isEnd = [System.Object]::ReferenceEquals($_, $script:EndObject)
                if ($isEnd) {
                    if ($lineGroupList.Count -ne 0) {
                        Write-Output ($lineGroupList -join "`n")
                        $lineGroupList.Clear()
                    }
                    $lineGroupList.Clear()
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
            | Where-Object {
                $_ -cne 'No result found.'
            }
            | Select-Object -SkipLast 1 `
            | ForEach-Object {
                $output = [PSCustomObject] @{
                    RowIndex   = $_ | Select-String -Pattern 'Row: (\d+)' | ForEach-Object { [int] $_.Matches[0].Groups[1].Value }
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
    }
}



function InvokeAdbExpressionInternal {

    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Command
    )

    process {
        Invoke-AdbExpression -DeviceId $id -Command $Command -Verbose:$VerbosePreference
    }

    end {
        Write-Output $script:EndObject
    }
}


# TODO: Add --user, --sort, and --extra options
# usage: adb shell content query --uri <URI> [--user <USER_ID>] [--projection <PROJECTION>] [--where <WHERE>] [--sort <SORT_ORDER>] [--extra <BINDING>...]
#   <PROJECTION> is a list of colon separated column names and is formatted:
#   <COLUMN_NAME>[:<COLUMN_NAME>...]
#   <SORT_ORDER> is the order in which rows in the result should be sorted.
#   Example:
#   # Select "name" and "value" columns from secure settings where "name" is equal to "new_setting" and sort the result by name in ascending order.
#   adb shell content query --uri content://settings/secure --projection name:value --where "name='new_setting'" --sort "name ASC"


# Use check if the current line is the last line of a row
$script:EndObject = @{}



# Examples of content URIs:
# - content://contacts/people
# - content://contacts/phones
# - content://com.android.contacts/contacts
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
