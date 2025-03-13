function Get-AdbSetting {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("Global", "System", "Secure")]
        [string] $Namespace,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [string[]] $Key,

        # Fast query of multiple values
        # Be careful with this parameter, as it relies on the assumption that no key contains '='
        [Parameter(ParameterSetName = "Default")]
        [switch] $QueryFromList,

        # Be careful with this parameter, as it relies on the assumption that no key contains '='
        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List,

        [ValidateSet('Default', 'ContentProvider')]
        [string] $Type = 'Default'
    )

    begin {
        $namespaceLowercase = switch ($Namespace) {
            "Global" { "global" }
            "System" { "system" }
            "Secure" { "secure" }
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 17
                continue
            }
            if (($List -or $QueryFromList) -and $apiLevel -lt 23) {
                Write-ApiLevelError -FeatureName 'List/QueryFromList parameter' -DeviceId $id -ApiLevelLessThan 23
                continue
            }
            if ($List) {
                switch ($Type) {
                    'Default' { 
                        Invoke-AdbExpression -DeviceId $id -Command "shell settings list $namespaceLowercase" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
                        | Out-String -Stream `
                        | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
                        | ForEach-Object {
                            $indexOfEqualsSymbol = $_.IndexOf('=')
                            if ($indexOfEqualsSymbol -eq -1) {
                                # It turns out that some settings have no equals symbol, so we just skip them
                                return
                            }
                            $itemKey = $_.Substring(0, $indexOfEqualsSymbol)
                            $itemValue = $_.Substring($indexOfEqualsSymbol + 1)
                            [PSCustomObject]@{
                                Key   = $itemKey
                                Value = $itemValue
                            }
                        }
                    }
                    'ContentProvider' {
                        Invoke-AdbExpression -DeviceId $id -Command "shell content query --uri content://settings/$namespaceLowercase" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
                        | Select-String -Pattern $script:ContentProviderSettingPattern -AllMatches `
                        | ForEach-Object {
                            $_.Matches
                        } `
                        | ForEach-Object {
                            [PSCustomObject]@{
                                Id                   = [long] $_.Groups["id"].Value
                                Key                  = $_.Groups["name"].Value
                                Value                = $_.Groups["value"].Value
                                IsPreservedInRestore = [bool]::Parse($_.Groups["isPreservedInRestore"].Value)
                            }
                        }
                    }
                }
                continue
            }

            $values = if ($QueryFromList) {
                switch ($Type) {
                    'Default' {
                        $properties = Get-AdbSetting -DeviceId $id -Namespace $Namespace -List -Verbose:$VerbosePreference
                        $targetProperties = foreach ($keyName in $Key) {
                            $properties | Where-Object {
                                $_.Key -ceq $keyName
                            } `
                            | Select-Object -First 1
                        }

                        $targetProperties | Where-Object { $_.Key -cin $Key } `
                        | Select-Object -ExpandProperty Value
                    }
                    'ContentProvider' {
                        $properties = Get-AdbSetting -DeviceId $id -Namespace $Namespace -Type 'ContentProvider' -List -Verbose:$VerbosePreference
                        $targetProperties = foreach ($keyName in $Key) {
                            $properties | Where-Object {
                                $_.Name -ceq $keyName
                            } `
                            | Select-Object -First 1
                        }

                        $targetProperties | Where-Object { $_.Name -cin $Key } `
                        | Select-Object -ExpandProperty Value
                    }
                }
            }
            else {
                $Key | ForEach-Object {
                    $keyName = $_
                    switch ($Type) {
                        'Default' {
                            Invoke-AdbExpression -DeviceId $id -Command "shell settings get $namespaceLowercase $keyName" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
                        }
                        'ContentProvider' {
                            Invoke-AdbExpression -DeviceId $id -Command "shell content query --uri content://settings/$namespaceLowercase --where ""name\ =\ \'$($keyName)\'""" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
                            | Select-String -Pattern $script:ContentProviderSettingPattern -AllMatches `
                            | ForEach-Object {
                                $_.Matches
                            } `
                            | ForEach-Object {
                                [PSCustomObject]@{
                                    Id                   = [long] $_.Groups["id"].Value
                                    Key                  = $_.Groups["name"].Value
                                    Value                = $_.Groups["value"].Value
                                    IsPreservedInRestore = [bool]::Parse($_.Groups["isPreservedInRestore"].Value)
                                }
                            }
                        }
                    }
                }
            }

            $values | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        }
    }
}




$script:ContentProviderSettingPattern = 'Row: (?<row>\d+) _id=(?<id>\d+), name=(?<name>[\w\.\\\/\d\:]+), value=(?<value>.+), is_preserved_in_restore=(?<isPreservedInRestore>(true|false))'
