function Test-AdbMobileDataConnection {

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
                Write-Error "Check mobile data connection is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 17 and above are supported."
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
