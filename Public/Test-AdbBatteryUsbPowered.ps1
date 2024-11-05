function Test-AdbBatteryUsbPowered {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference `
            | Select-String -Pattern "  USB powered: (\w+)" -AllMatches `
            | ForEach-Object {
                $usbPowered = $_.Matches.Groups[1].Value -eq "true"
                $usbPowered
            }
        }
    }
}
