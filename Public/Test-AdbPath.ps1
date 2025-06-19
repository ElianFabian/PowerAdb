function Test-AdbPath {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $LiteralRemotePath,

        [ValidateSet('Any', 'Container', 'Leaf')]
        [string] $PathType = 'Any',

        [switch] $RunAs
    )

    if ($RunAs) {
        $runAsCommand = " run-as '$RunAs'"
    }
    $pathTypeArg = switch ($PathType) {
        'Any' { '-e' }
        'Container' { '-d' }
        'Leaf' { '-f' }
    }

    foreach ($path in $LiteralRemotePath) {
        $sanitizedLiteralRemotePath = ConvertTo-ValidAdbStringArgument $path
        $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell$runAsCommand [ $pathTypeArg $sanitizedLiteralRemotePath ] && echo 1 || echo 0" -Verbose:$VerbosePreference
        switch ($result) {
            '1' { $true }
            '0' { $false }
        }
    }
}
