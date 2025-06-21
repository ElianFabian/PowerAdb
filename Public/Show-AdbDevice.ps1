function Show-AdbDevice {

    $devices = Get-AdbDeviceDetail -Verbose:$false

    Write-Host

    if (-not $devices) {
        Write-Error "There are no available devices right now"
        Write-Host
        return
    }

    $names = $devices.Model
    if ($names) {
        $longestDeviceNameLength = $names | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    }
    else {
        $longestDeviceNameLength = 5
    }

    $longestIdLength = $devices.SerialNumber | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum


    $spaceSize = 5

    $header = "$("Serial Number".PadRight($longestIdLength + $spaceSize, ' '))$("Name".PadRight($longestDeviceNameLength + $spaceSize, ' '))$("API Level".PadRight($longestDeviceNameLength + 0, ' '))State"
    $header += "`n$("-------------".PadRight($longestIdLength + $spaceSize, ' '))$("----".PadRight($longestDeviceNameLength + $spaceSize, ' '))$("---------".PadRight($longestDeviceNameLength + 0, ' '))-----"

    Write-Host $header -ForegroundColor Green

    foreach ($device in $devices) {
        $deviceName = if ($device.State -ne 'offline' -and (Test-AdbEmulator -SerialNumber $device.SerialNumber)) {
            Get-AdbDeviceName -SerialNumber $device.SerialNumber
        }
        else {
            $device.Model
        }
        if (-not $deviceName) {
            $deviceName = '-'
        }

        if ($device.State -ne 'offline') {
            $apiLevel = Get-AdbApiLevel -SerialNumber $device.SerialNumber -Verbose:$false -ErrorAction Ignore
        }
        if (-not $apiLevel) {
            $apiLevel = '-'
        }

        Write-Host $device.SerialNumber.PadRight($longestIdLength + $spaceSize, ' ') -NoNewline -ForegroundColor Cyan
        Write-Host $deviceName.PadRight($longestDeviceNameLength + $spaceSize, ' ') -NoNewline -ForegroundColor DarkCyan
        Write-Host $apiLevel.ToString().PadRight($longestDeviceNameLength + 0, ' ') -NoNewline -ForegroundColor White
        Write-Host $device.State -ForegroundColor White
    }

    Write-Host
}
