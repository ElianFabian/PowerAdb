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
        [string] $Key,

        # If any Key contains '=' then output will be wrong
        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List
    )

    begin {
        $Key = [string] $PSBoundParameters['Key']
        if ($Key.Contains(" ")) {
            Write-Error "Key '$Key' can't contain space characters"
            return
        }

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
                Invoke-AdbExpression -DeviceId $id -Command "shell settings list $namespaceLowercase" `
                | Out-String -Stream `
                | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
                | ForEach-Object {
                    $indexOfEqualsSymbol = $_.IndexOf('=')
                    $itemKey = $_.Substring(0, $indexOfEqualsSymbol)
                    $itemValue = $_.Substring($indexOfEqualsSymbol + 1)
                    [PSCustomObject]@{
                        Key   = $itemKey
                        Value = $itemValue
                    }
                }
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell settings get $namespaceLowercase $Key" `
            | Out-String -Stream `
            | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        }
    }
}
