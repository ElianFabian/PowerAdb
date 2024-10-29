function Remove-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [switch] $Force,

        [switch] $Recurse
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
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell ""rm $params '$LiteralRemotePath'""" -Verbose:$VerbosePreference
        }
    }
}
