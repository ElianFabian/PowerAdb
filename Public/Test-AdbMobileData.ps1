function Test-AdbMobileData {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $result = Get-AdbSetting -SerialNumber $SerialNumber -Namespace global -Name 'mobile_data' -Verbose:$VerbosePreference

    switch ($result) {
        '1' { $true }
        '0' { $false }
        default { $null }
    }
}
