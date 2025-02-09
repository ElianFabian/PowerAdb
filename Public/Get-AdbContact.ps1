# For this function to work we rely on the assumption that any field value contains an equal ('=') character.
# Otherwise, the function will not work as expected.
function Get-AdbContact {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [long] $Id = $null
    )

    begin {
        if ($Id) {
            $contactIdArg = "/$Id"
        }
    }

    process {
        foreach ($device in $DeviceId) {
            Invoke-AdbExpression -DeviceId $device -Command "shell content query --uri content://contacts/people$contactIdArg" -Verbose:$VerbosePreference `
            | Where-Object { $_ -notlike '*No result found.*' } `
            | Out-String -Stream `
            | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
            | ForEach-Object {
                $rawContactData = $_ -replace 'Row: \d+ ', ''

                [string[]] $pairs = $rawContactData -split '='
                $firstKey = $pairs[0]
                $lastValue = $pairs[$pairs.Length - 1]

                $keyAndValues = New-Object System.Collections.Generic.List[string]

                $keyAndValues.Add($firstKey)
                $pairs | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ForEach-Object {
                    $valueAndKey = $_
                    $key = [System.Text.StringBuilder]::new()
                    $value = [System.Text.StringBuilder]::new()
                    $firstSpaceFound = $false

                    for ($i = $valueAndKey.Length - 1; $i -ge 0; $i--) {
                        $currentChar = $valueAndKey[$i]

                        if ($currentChar -eq ' ' -and -not $firstSpaceFound) {
                            $firstSpaceFound = $true
                            $i-- # Skip the following comma
                            continue
                        }
                        if (-not $firstSpaceFound) {
                            $key.Insert(0, $currentChar) > $null
                        }
                        else {
                            $value.Insert(0, $currentChar) > $null
                        }
                    }

                    $keyAndValues.Add($value.ToString())
                    $keyAndValues.Add($key.ToString())
                }
                $keyAndValues.Add($lastValue)

                $rawFields = @{}
                for ($i = 0; $i -lt $keyAndValues.Count; $i += 2) {
                    $key = $keyAndValues[$i]
                    $value = $keyAndValues[$i + 1]
                    $rawFields[$key] = $value
                }

                $rawFields.GetEnumerator() | ForEach-Object {
                    $key = $_.Key
                    $value = $_.Value

                    switch ($key) {
                        '_id' {
                            $contactId = [uint32] $value
                        }
                        'name' {
                            $contactName = $value
                        }
                        'phonetic_name' {
                            $contactPhoneticName = $value
                        }
                        'number' {
                            $contactNumber = $value
                        }
                        'notes' {
                            $contactNotes = $value
                        }
                        'starred' {
                            $contactStarred = if ($value -eq '1') { $true } else { $false }
                        }
                        'send_to_voicemail' {
                            $contactSendToVoicemail = if ($value -eq '1') { $true } else { $false }
                        }
                    }
                }

                [PSCustomObject] @{
                    Id              = $contactId
                    Name            = $contactName
                    PhoneticName    = $contactPhoneticName
                    Number          = $contactNumber
                    Notes           = $contactNotes
                    Starred         = $contactStarred
                    SendToVoicemail = $contactSendToVoicemail
                }
            }
        }
    }
}

# To see later:
# - content://com.android.contacts/data
# - content://com.android.contacts/data/emails
