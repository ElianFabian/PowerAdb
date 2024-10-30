function Test-AdbPath {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [switch] $RunAs
    )

    begin {
        if ($RunAs) {
            $runAsCommand = " run-as '$RunAs'"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $result = Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand [ -e '$LiteralRemotePath' ] && echo '1' || echo '0'" -Verbose:$VerbosePreference 2> $null
            switch ($result) {
                '1' { $true }
                '0' { $false }
            }
        }
    }
}
