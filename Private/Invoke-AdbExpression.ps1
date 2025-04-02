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
        $availableDevices = Get-AdbDevice -Verbose:$false
        if ($availableDevices.Count -eq 0 -and $DeviceId) {
            $stopExecution = $true
            $errorMessage = 'No device connected'
        }
        $separator = ""
        foreach ($id in $DeviceId) {
            if ($id -notin $availableDevices) {
                $stopExecution = $true
                $errorMessage += "$($separator)There's no device with id '$id' connected"
                $separator = "`n"
            }
        }
    }

    process {
        if ($stopExecution) {
            Write-Error $errorMessage -ErrorAction Stop
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
                    $adbCommand = "adb -s '$id' $Command"
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
