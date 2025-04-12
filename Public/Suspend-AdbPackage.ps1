function Suspend-AdbPackage {

    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [AllowNull()]
        [object] $UserId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm suspend$userArg '$package'" -Verbose:$VerbosePreference > $null
    }
}
