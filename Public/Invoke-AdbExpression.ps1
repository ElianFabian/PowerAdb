function Invoke-AdbExpression {

    [OutputType([string[]])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Command
    )

    begin {
        $availableDevicesCount = (adb devices).Count - 2
        if ($availableDevicesCount -eq 0) {
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
                if ($PSCmdlet.ShouldProcess("adb $Command")) {
                    Write-Verbose "adb $Command"
                    Invoke-Expression "adb $Command"
                }
            }
            else {
                $DeviceId | ForEach-Object {
                    if ($PSCmdlet.ShouldProcess("adb -s $_ $Command")) {
                        Write-Verbose "adb -s $_ $Command"
                        Invoke-Expression "adb -s $_ $Command"
                    }
                }
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousEncoding
        }
    }
}
