function Test-AdbMobileData {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 17
                continue
            }

            Get-AdbSetting -DeviceId $id -Namespace Global -Key "mobile_data" -Verbose:$VerbosePreference `
            | ForEach-Object {
                switch ($_) {
                    "1" { $true }
                    "0" { $false }
                    default { $null }
                }
            }
        }
    }
}
