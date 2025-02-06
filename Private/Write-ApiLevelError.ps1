function Write-ApiLevelError {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [string] $FeatureName = (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [Parameter(Mandatory)]
        [int] $ApiLevelLessThan
    )

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId

    $message = "'$FeatureName' is not supported for device with id '$DeviceId' with API level of '$apiLevel'. Only API levels $ApiLevelLessThan and above are supported."
    Write-Error -Message $message
}
