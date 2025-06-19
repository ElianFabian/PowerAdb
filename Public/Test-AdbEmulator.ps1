function Test-AdbEmulator {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string] $SerialNumber
    )

    $SerialNumber.StartsWith("emulator-")
}
