function Invoke-AdbScreenShot {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Destination
    )

    process {
        foreach ($id in $DeviceId) {
            $adbCommand = "adb -s $id exec-out screencap -p > '$Destination'"

            # https://stackoverflow.com/a/59118502/18418162
            if ($IsWindows) {
                if ($VerbosePreference) {
                    Write-Verbose "cmd /c $adbCommand"
                }
                cmd /c $adbCommand
            }
            elseif ($IsMacOS -or $IsLinux) {
                if ($VerbosePreference) {
                    Write-Verbose "sh -c $adbCommand"
                }
                bash -c $adbCommand
            }
            else {
                Write-Error "Unsupported platform. This script only works on Windows, MacOS, and Linux."
            }
        }
    }
}
