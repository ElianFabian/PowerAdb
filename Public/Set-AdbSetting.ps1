function Set-AdbSetting {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [ValidateSet('global', 'system', 'secure')]
        [string] $Namespace,

        [Parameter(Mandatory)]
        [string[]] $Name,

        # New line characters are ignored
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    if ($Name.Contains(' ')) {
        Write-Error "Name '$Name' can't contain space characters"
        return
    }
    if ($Name.Contains('=')) {
        # This is not a real restriction, we rely on this to proper parse key-value pairs in 'Get-AdbSetting -List'
        # this is the format: key=value
        Write-Error "Name '$Name' can't contain the character '='"
        return
    }

    $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value

    foreach ($settingName in $Name) {
        try {
            $sanitizedSettingName = ConvertTo-ValidAdbStringArgument $settingName
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell settings put $Namespace $sanitizedSettingName $sanitizedValue" -Verbose:$VerbosePreference
        }
        catch { [AdbCommandException]
            if ($_.Exception.Message.Contains('java.lang.SecurityException: com.android.shell was not granted  this permission: android.permission.WRITE_SETTINGS')) {
                Write-Error "Couldn't set setting, you probably need to go to developer settings and turn on 'Disable permission monitoring'. For more info check this link: https://stackoverflow.com/a/72949330/18418162"
            }
            throw $_
        }
    }
}
