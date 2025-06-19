function Resolve-AdbDevice {

    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [switch] $IgnoreExecutionCheck
    )

    if ($SerialNumber) {
        Assert-ValidAdbStringArgument $SerialNumber -ArgumentName 'SerialNumber'
    }

    if (-not $IgnoreExecutionCheck) {
        Assert-AdbExecution -SerialNumber $SerialNumber
    }

    $availableDevices = Get-AdbDevice -Verbose:$false

    if ($SerialNumber -and $SerialNumber -in $availableDevices) {
        return $SerialNumber
    }

    return $availableDevices | Select-Object -First 1
}
