function Test-AdbAirPlaneMode {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    $result = Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd connectivity airplane-mode' -Verbose:$VerbosePreference
    switch ($result) {
        'enabled' { $true }
        'disabled' { $false }
    }
}
