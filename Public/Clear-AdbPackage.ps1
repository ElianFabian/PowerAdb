function Clear-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    foreach ($package in $PackageName) {
        $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm clear$userArg $package" -Verbose:$VerbosePreference
        Write-Verbose "Clear data in device with id '$DeviceId' from '$package': $result"
    }
}
