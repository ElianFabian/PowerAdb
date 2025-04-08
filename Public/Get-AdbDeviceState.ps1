function Get-AdbDeviceState {

    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $state = Invoke-AdbExpression -DeviceId $id -Command "get-state" -Verbose:$VerbosePreference -ErrorAction SilentlyContinue 2>&1
            if ($state -isnot [System.Management.Automation.ErrorRecord]) {
                $state
            }
            else {
                "offline"
            }
        }
    }
}
