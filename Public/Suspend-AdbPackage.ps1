function Suspend-AdbPackage {

    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [AllowNull()]
        [object] $UserId
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 28

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm suspend$userArg '$package'" -Verbose:$VerbosePreference > $null
    }
}
