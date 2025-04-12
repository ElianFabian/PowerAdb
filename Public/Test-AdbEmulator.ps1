function Test-AdbEmulator {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId
    )

    $DeviceId.StartsWith("emulator-")
}
