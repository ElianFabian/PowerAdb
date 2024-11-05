function Test-AdbDarkMode {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if ($apiLevel -lt 29) {
                $false
            }
            else {
                Invoke-AdbExpression -DeviceId $id -Command "shell cmd uimode night" -Verbose:$VerbosePreference `
                | ForEach-Object {
                    switch ($_) {
                        'Night mode: no' { $false }
                        'Night mode: yes' { $true }
                        default {
                            Write-Error "Couldn't determine if device with id '$id' is in dark mode"
                        }
                    }
                }
            }
        }
    }
}
