function Test-AdbAirPlaneMode {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 28

    $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell cmd connectivity airplane-mode' -Verbose:$VerbosePreference
    switch ($result) {
        'enabled' { $true }
        'disabled' { $false }
    }
}
