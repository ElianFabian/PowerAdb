function Invoke-AdbItem {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [string] $DeviceId,

        [string] $LiteralRemotePath,

        [Parameter(Mandatory, ParameterSetName = 'CustomComponent')]
        [string] $PackageName,

        [Parameter(Mandatory, ParameterSetName = 'CustomComponent')]
        [string] $ComponentClassName
    )

    $defaultBrowserComponent = if ($PSCmdlet.ParameterSetName -eq 'Default') {
        Resolve-AdbActivity -DeviceId $DeviceId -Intent (New-AdbIntent -Action 'android.intent.action.VIEW' -Data 'http://www.google.com') -Verbose:$false
    }
    else {
        [PSCustomObject]@{
            PackageName        = $PackageName
            ComponentClassName = $ComponentClassName
        }
    }

    $intent = New-AdbIntent -Action 'android.intent.action.VIEW' -Data "file://$LiteralRemotePath" -ComponentClassName $defaultBrowserComponent.ComponentClassName -PackageName $defaultBrowserComponent.PackageName
    Start-AdbActivity -DeviceId $DeviceId -Intent $intent -Verbose:$VerbosePreference
}
