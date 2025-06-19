function Remove-AdbSetting {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [ValidateSet("global", "system", "secure")]
        [string] $Namespace,

        [Parameter(Mandatory)]
        [string[]] $Name
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 21

    foreach ($settingName in $Name) {
        if ($settingName.Contains(" ")) {
            Write-Error "Setting name '$settingName' can't contain space characters" -ErrorAction Stop
        }
    }

    foreach ($settingName in $Name) {
        $sanitizedSettingName = ConvertTo-ValidAdbStringArgument $settingName
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell settings delete $Namespace $sanitizedSettingName" -Verbose:$VerbosePreference
    }
}
