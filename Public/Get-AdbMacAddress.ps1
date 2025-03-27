function Get-AdbMacAddress {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    foreach ($id in $DeviceId) {
        Invoke-AdbExpression -DeviceId $id -Command 'shell ip address show wlan0' -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
        | Select-String -Pattern 'link/ether (.+) brd' `
        | ForEach-Object {
            $_.Matches.Groups[1].Value
        }
    }
}
