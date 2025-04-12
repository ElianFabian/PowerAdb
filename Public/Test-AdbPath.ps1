function Test-AdbPath {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

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
        $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand [ $pathTypeArg $sanitizedLiteralRemotePath ] && echo 1 || echo 0" -Verbose:$VerbosePreference
        switch ($result) {
            '1' { $true }
            '0' { $false }
        }
    }
}
