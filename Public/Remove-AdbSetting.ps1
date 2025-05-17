function Remove-AdbSetting {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("global", "system", "secure")]
        [string] $Namespace,

        [Parameter(Mandatory)]
        [string[]] $Name
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 21

    foreach ($settingName in $Name) {
        if ($settingName.Contains(" ")) {
            Write-Error "Setting name '$settingName' can't contain space characters" -ErrorAction Stop
        }
    }

    foreach ($settingName in $Name) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell settings delete $Namespace '$settingName'" -Verbose:$VerbosePreference
    }
}
