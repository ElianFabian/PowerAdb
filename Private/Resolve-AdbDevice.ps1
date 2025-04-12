function Resolve-AdbDevice {

    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $DeviceId
    )

    Assert-AdbExecution -DeviceId $DeviceId

    $availableDevices = Get-AdbDevice -Verbose:$false

    if ($DeviceId -and $DeviceId -in $availableDevices) {
        return $DeviceId
    }

    return $availableDevices | Select-Object -First 1
}
