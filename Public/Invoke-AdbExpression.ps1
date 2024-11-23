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
        $availableDevicesCount = (adb devices).Count - 2
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

            if (-not $DeviceId) {
                $adbCommand = "adb $Command"
                if ($PSCmdlet.ShouldProcess($adbCommand, '', 'Invoke-AdbExpression')) {
                    Invoke-Expression $adbCommand | Repair-OutputRendering
                }
            }
            else {
                foreach ($id in $DeviceId) {
                    $adbCommand = "adb -s $id $Command"
                    if ($PSCmdlet.ShouldProcess($adbCommand, '', 'Invoke-AdbExpression')) {
                        Invoke-Expression $adbCommand | Repair-OutputRendering
                    }
                }
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousEncoding
        }
    }
}
