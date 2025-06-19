function Invoke-AdbItem {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [string] $LiteralRemotePath,

        [Parameter(Mandatory, ParameterSetName = 'CustomComponent')]
        [string] $PackageName,

        [Parameter(Mandatory, ParameterSetName = 'CustomComponent')]
        [string] $ComponentClassName
    )

    $defaultBrowserComponent = if ($PSCmdlet.ParameterSetName -eq 'Default') {
        Resolve-AdbActivity -SerialNumber $SerialNumber -Intent (New-AdbIntent -Action 'android.intent.action.VIEW' -Data 'http://www.google.com') -Verbose:$false
    }
    else {
        [PSCustomObject]@{
            PackageName        = $PackageName
            ComponentClassName = $ComponentClassName
        }
    }

    $intent = New-AdbIntent -Action 'android.intent.action.VIEW' -Data "file://$LiteralRemotePath" -ComponentClassName $defaultBrowserComponent.ComponentClassName -PackageName $defaultBrowserComponent.PackageName
    Start-AdbActivity -SerialNumber $SerialNumber -Intent $intent -Verbose:$VerbosePreference
}
