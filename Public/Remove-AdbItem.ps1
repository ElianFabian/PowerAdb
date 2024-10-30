function Remove-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [switch] $Force,

        [switch] $Recurse,

        [string] $RunAs
    )

    begin {
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
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand ""rm $params '$LiteralRemotePath'""" -Verbose:$VerbosePreference
        }
    }
}
