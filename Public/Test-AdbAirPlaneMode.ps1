function Test-AdbAirPlaneMode {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 28) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 28
                continue
            }

            $result = Invoke-AdbExpression -DeviceId $id -Command 'shell cmd connectivity airplane-mode' -Verbose:$VerbosePreference
            switch ($result) {
                'enabled' { $true }
                'disabled' { $false }
            }
        }
    }
}
