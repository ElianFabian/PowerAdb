function Invoke-AdbScreenShot {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Destination,

        [switch] $Force
    )

    begin {
        $actualDestination = "$Destination.png"
    }

    process {
        if (-not $Force -and (Test-Path $actualDestination)) {
            Write-Error "The file '$actualDestination' already exists. Use -Force to overwrite."
            return
        }
        foreach ($id in $DeviceId) {
            $adbCommand = "adb -s $id exec-out screencap -p > ""$actualDestination"""

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

            if (-not $PSCmdlet.ShouldProcess($actualCommand)) {
                return
            }

            if ($VerbosePreference) {
                Write-Verbose $actualCommand
            }
            Invoke-Expression $actualCommand
        }
    }
}
