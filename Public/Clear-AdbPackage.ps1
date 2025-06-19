function Clear-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    foreach ($package in $PackageName) {
        $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm clear$userArg $package" -Verbose:$VerbosePreference
        Write-Verbose "Clear data in device with serial number '$SerialNumber' from '$package': $result"
    }
}
