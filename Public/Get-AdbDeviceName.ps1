function Get-AdbDeviceName {

    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $cachedDeviceName = Get-CacheValue -DeviceId $id -ErrorAction SilentlyContinue
            if ($null -ne $cachedDeviceName) {
                Write-Verbose "Get cached device name for device with id '$id'"
                [string] $cachedDeviceName
            }
            else {
                $result = if ((Test-AdbEmulator -DeviceId $id)) {
                    [string] (Invoke-AdbExpression -DeviceId $id -Command 'emu avd name' -Verbose:$VerbosePreference | Select-Object -First 1)
                }
                else {
                    Get-AdbProperty -DeviceId $id -Name 'ro.product.model' -Verbose:$VerbosePreference
                }

                Set-CacheValue -DeviceId $id -Value $result

                [string] $result
            }
        }
    }
}
