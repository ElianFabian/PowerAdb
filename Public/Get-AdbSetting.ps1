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
        [switch] $List
    )

    begin {
        $namespaceLowercase = $Namespace.ToLower()
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-Error "Settings is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 17 and above are supported."
                continue
            }
            if ($List) {
                if ($apiLevel -lt 23) {
                    Write-Error "List parameter is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 23 and above are supported."
                    continue
                }
                Invoke-AdbExpression -DeviceId $id -Command "shell settings list $namespaceLowercase" -Verbose:$VerbosePreference `
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
                continue
            }


            $values = if ($QueryFromList) {
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
            else {
                $Key | ForEach-Object {
                    Invoke-AdbExpression -DeviceId $id -Command "shell settings get $namespaceLowercase $_" -Verbose:$VerbosePreference
                }
            }

            $values | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        }
    }
}
