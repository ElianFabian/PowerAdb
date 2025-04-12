function Get-AdbLocalNetworkIp {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [switch] $Wait
    )

    # This might seem weird, but at least on emulators 'ip' is not available for API level 18.
    Assert-ApiLevel -DeviceId $DeviceId -NotEqualTo 18

    do {
        if ($Wait) {
            Wait-AdbDeviceState -DeviceId $DeviceId -State 'device' -Verbose:$VerbosePreference
        }

        $ipAddress = Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell ip route' -Verbose:$VerbosePreference `
        | Select-String -Pattern '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/\d+ dev\s+[\w\d]+\s+proto\s+kernel\s+scope\s+link\s+src\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)' `
        | ForEach-Object {
            $_.Matches.Groups[1].Value
        }
    }
    while (-not $ipAddress -and $Wait)

    return $ipAddress
}
