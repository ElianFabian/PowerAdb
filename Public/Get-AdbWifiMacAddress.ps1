function Get-AdbWifiMacAddress {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    # This might seem weird, but at least on emulators 'ip' is not available for API level 18.
    Assert-ApiLevel -SerialNumber $SerialNumber -NotEqualTo 18

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell ip address show wlan0' -Verbose:$VerbosePreference `
    | Select-String -Pattern 'link/ether (.+) brd' `
    | ForEach-Object {
        $_.Matches.Groups[1].Value
    }
}
