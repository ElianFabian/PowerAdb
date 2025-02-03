function Get-AdbLocalNetworkIp {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [switch] $Wait
    )

    process {
        foreach ($id in $DeviceId) {
            do {
                if ($Wait) {
                    Wait-AdbState -DeviceId $id -State "Device" -Verbose:$VerbosePreference
                }
                $ipAddress = Invoke-AdbExpression -DeviceId $id -Command "shell ip -f inet addr show wlan0" `
                    -Verbose:$VerbosePreference `
                    -WhatIf:$false `
                    -Confirm:$false `
                | Select-String -Pattern "inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)" `
                | ForEach-Object {
                    $_.Matches.Groups[1].Value
                }
            }
            while (-not $ipAddress -and $Wait)

            $ipAddress
        }
    }
}
