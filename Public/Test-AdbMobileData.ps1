function Test-AdbMobileData {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    $result = Get-AdbSetting -DeviceId $DeviceId -Namespace global -Name 'mobile_data' -Verbose:$VerbosePreference

    switch ($result) {
        '1' { $true }
        '0' { $false }
        default { $null }
    }
}
