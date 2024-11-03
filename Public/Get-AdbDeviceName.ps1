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
                $deviceName = if ((Test-AdbEmulator -DeviceId $id)) {
                    [string] (Invoke-AdbExpression -DeviceId $id -Command 'emu avd name' -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false | Select-Object -First 1)
                }
                else {
                    Get-AdbProperty -DeviceId $id -Name 'ro.product.model' -Verbose:$VerbosePreference
                }

                if ($deviceName) {
                    Set-CacheValue -DeviceId $id -Value $deviceName
                    [string] $deviceName
                }
                else {
                    if ($id -in (Get-AdbDevice)) {
                        Write-Warning "Failed to get device name for device with id '$id'."
                    }
                    else {
                        Write-Warning "Failed to get device name for device with id '$id'. There is no device with id '$id' connected."
                    }
                }
            }
        }
    }
}
