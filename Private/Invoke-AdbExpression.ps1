function Invoke-AdbExpression {

    [OutputType([string[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Command
    )

    begin {
        $availableDevicesCount = (Get-AdbDevice -Verbose:$false).Count
        if ($availableDevicesCount -eq 0 -and $DeviceId) {
            Write-Warning "There are no available devices"
            $stopExecution = $true
        }
    }

    process {
        if ($stopExecution) {
            return
        }

        if (-not $PSBoundParameters.ContainsKey('DeviceId')) {
            if ($availableDevicesCount -gt 1) {
                Write-Error "There are multiple devices connected, you have to indicate the device id"
                return
            }
        }

        try {
            $previousEncoding = [System.Console]::OutputEncoding
            [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

            AdbInternal -DeviceId $DeviceId -Command $Command -Verbose:$VerbosePreference
        }
        finally {
            [System.Console]::OutputEncoding = $previousEncoding
        }
    }
}
