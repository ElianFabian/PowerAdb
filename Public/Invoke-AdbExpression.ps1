function Invoke-AdbExpression {

    [OutputType([string[]])]
    [CmdletBinding()]
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
            return
        }
    }

    process {
        if (-not $PSBoundParameters.ContainsKey('DeviceId')) {
            if ($availableDevicesCount -gt 1) {
                Write-Error "There are multiple devices connected, you have to indicate the device id"
                return
            }
        }

        try {
            $previousEncoding = [System.Console]::OutputEncoding
            # We have to ensure that the encoding is UTF-8 for adb to show correct ouput
            [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

            if (-not $DeviceId) {
                Write-Verbose "adb $Command"

                # I don't like using Invoke-Expression, but it's the best solution I found
                return Invoke-Expression "adb $Command"
            }

            $DeviceId | ForEach-Object {
                Write-Verbose "adb -s $_ $Command"

                Invoke-Expression "adb -s $_ $Command"
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousEncoding
        }
    }
}
