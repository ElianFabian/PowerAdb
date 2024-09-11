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
            $adbCommand = "adb -s $id exec-out screencap -p > ""$Destination"""

            # https://stackoverflow.com/a/59118502/18418162
            if ($IsWindows -or -not $IsCoreCLR) {
                $actualCommand = "cmd /c $adbCommand"
            }
            elseif ($IsMacOS -or $IsLinux) {
                $actualCommand = "sh -c $adbCommand"
            }
            else {
                Write-Error "Unsupported platform. This script only works on Windows, MacOS, and Linux."
                continue
            }

            & $actualCommand
            if ($VerbosePreference) {
                Write-Verbose "$actualCommand"
            }
        }
    }
}
