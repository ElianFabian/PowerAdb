function Invoke-AdbScreenShot {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Destination,

        [switch] $Force
    )

    Assert-AdbExecution -SerialNumber $SerialNumber
    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 20

    # This might seem weird, but at least on emulators 'screencap' is not available for API level 25.
    Assert-ApiLevel -SerialNumber $SerialNumber -NotEqualTo 25

    $actualDestination = "$Destination.png"

    if (-not $Force -and (Test-Path $actualDestination)) {
        if (Test-Path $actualDestination -PathType Container) {
            Write-Error "The path '$actualDestination' is a directory. Please specify a file name." -ErrorAction Stop
        }
        Write-Error "The file '$actualDestination' already exists. Use -Force to overwrite." -ErrorAction Stop
    }

    if ($SerialNumber) {
        $serialNumberArg = " -s '$SerialNumber'"
    }

    $adbCommand = "adb$serialNumberArg exec-out screencap -p > ""$actualDestination"""

    # https://stackoverflow.com/a/59118502/18418162
    if ($IsWindows -or -not $IsCoreCLR) {
        $actualCommand = "cmd /c $adbCommand"
    }
    elseif ($IsMacOS -or $IsLinux) {
        $actualCommand = "sh -c $adbCommand"
    }
    else {
        Write-Error "Unsupported platform. This script only works on Windows, MacOS, and Linux." -ErrorAction Stop
    }

    if (-not $PSCmdlet.ShouldProcess($actualCommand, '', 'Invoke-AdbScreenShot')) {
        return
    }

    Invoke-Expression $actualCommand
}
