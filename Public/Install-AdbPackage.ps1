function Install-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string[]] $Path,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory, ParameterSetName = 'LiteralPath')]
        [string[]] $LiteralPath

        # [switch] $Replace,

        # [switch] $AllowTestPackages,

        # # Only for debuggable apps
        # [switch] $AllowDowngrade,

        # [switch] $Partial

        # It seems that in some API levels this does not exist, even though
        # it appears on the adb help in the version it doesn't work
        # We won't add it yet
        # [Parameter(Mandatory)]
        # [switch] $GrantAllRantimePermissions
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId -CurrentUserAsNull -RequireApiLevel 21
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    # In certain API levels the default behavior is to prevent installing
    # if the app is already installed
    if ($Replace) {
        $replaceArg = "-r "
    }

    $items = switch ($PSCmdlet.ParameterSetName) {
        Path { Get-Item -Path $Path }
        LiteralPath { Get-Item -LiteralPath $LiteralPath }
    }
    foreach ($item in $items) {
        # Sanitizing doesn't work for the path in here
        $itemPathArg = " '$($item.FullName)'"
        Assert-ValidAdbStringArgument $itemPathArg -ArgumentName 'LiteralPath'
        Invoke-AdbExpression -DeviceId $DeviceId -Command "install $replaceArg$userArg$itemPathArg" -Verbose:$VerbosePreference
    }
}
