function Get-AdbDeviceDetail {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param ()

    Write-Verbose "adb devices -l"

    adb devices -l | Select-Object -Skip 1 -SkipLast 1 `
    | ForEach-Object {
        $parts = $_ -split '\s+'

        if ($parts.Count -eq 3) {
            return [PSCustomObject]@{
                Id          = $parts[0]
                State       = $parts[1]
                TransportId = $parts[2].Replace('transport_id:', '')
            }
        }

        return [PSCustomObject]@{
            SerialNumber = $parts[0]
            State        = $parts[1]
            Product      = $parts[2].Replace('product:', '')
            Model        = $parts[3].Replace('model:', '')
            Device       = $parts[4].Replace('device:', '')
            TransportId  = $parts[5].Replace('transport_id:', '')
        }
    }
}
