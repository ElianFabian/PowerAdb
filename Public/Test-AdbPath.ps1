function Test-AdbPath {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath
    )

    process {
        foreach ($id in $DeviceId) {
            $result = Invoke-AdbExpression -DeviceId $id -Command "shell [ -e '$LiteralRemotePath' ] && echo '1' || echo '0'" -Verbose:$VerbosePreference
            switch ($result) {
                '1' { $true }
                '0' { $false }
            }
        }
    }
}
