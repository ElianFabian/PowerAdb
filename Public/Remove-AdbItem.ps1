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

        if ($RunAs) {
            $runAsCommand = " run-as '$RunAs'"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $isDirectory = (Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand [ -e '$LiteralRemotePath' ] && echo '1' || echo '0'" -Verbose:$false -WhatIf:$false 2> $null) -eq '1'
            if ($isDirectory -and -not $Force -and -not $Recurse) {
                Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand ""rmdir '$LiteralRemotePath'""" -Verbose:$VerbosePreference
            }
            else {
                Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand ""rm $params '$LiteralRemotePath'""" -Verbose:$VerbosePreference
            }
        }
    }
}
