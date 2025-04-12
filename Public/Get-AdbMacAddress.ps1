function Get-AdbMacAddress {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    # This might seem weird, but at least on emulators 'ip' is not available for API level 18.
    Assert-ApiLevel -DeviceId $DeviceId -NotEqualTo 18

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell ip address show wlan0' -Verbose:$VerbosePreference `
    | Select-String -Pattern 'link/ether (.+) brd' `
    | ForEach-Object {
        $_.Matches.Groups[1].Value
    }
}
