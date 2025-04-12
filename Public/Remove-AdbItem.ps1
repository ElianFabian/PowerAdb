function Remove-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [switch] $Force,

        [switch] $Recurse,

        [string] $RunAs
    )

    $params = if ($Force) {
        '-f'
    }
    elseif ($Recurse) {
        '-r'
    }
    elseif ($Force -and $Recurse) {
        '-rf'
    }
    else {
        ''
    }

    if ($RunAs) {
        $runAsCommand = " run-as '$RunAs'"
    }

    $isDirectory = (Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand [ -e '$LiteralRemotePath' ] && echo '1' || echo '0'" 2> $null) -eq '1'
    if ($isDirectory -and -not $Force -and -not $Recurse) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand ""rmdir '$LiteralRemotePath'""" -Verbose:$VerbosePreference
    }
    else {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand ""rm $params '$LiteralRemotePath'""" -Verbose:$VerbosePreference
    }
}
