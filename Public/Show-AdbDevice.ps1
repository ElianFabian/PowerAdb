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

    $longestIdLength = $devices.Id | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum


    $spaceSize = 5

    $header = "$("DeviceId".PadRight($longestIdLength + $spaceSize, " "))$("Name".PadRight($longestDeviceNameLength + $spaceSize, " "))$("API Level".PadRight($longestDeviceNameLength + $spaceSize, " "))State"
    $header += "`n$("--------".PadRight($longestIdLength + $spaceSize, " "))$("----".PadRight($longestDeviceNameLength + $spaceSize, " "))$("---------".PadRight($longestDeviceNameLength + $spaceSize, " "))-----"

    Write-Host $header -ForegroundColor Green

    foreach ($device in $devices) {
        $deviceName = if (Test-AdbEmulator -DeviceId $device.Id) {
            Get-AdbDeviceName -DeviceId $device.Id
        }
        else {
            $device.Model
        }
        if (-not $deviceName) {
            $deviceName = "-"
        }

        $apiLevel = Get-AdbApiLevel -DeviceId $device.Id -Verbose:$false -ErrorAction Ignore

        Write-Host $device.Id.PadRight($longestIdLength + $spaceSize, " ") -NoNewline -ForegroundColor Cyan
        Write-Host $deviceName.PadRight($longestDeviceNameLength + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        if (-not $apiLevel) {
            Write-Host "-".PadRight($longestDeviceNameLength + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        }
        else {
            Write-Host $apiLevel.ToString().PadRight($longestDeviceNameLength + $spaceSize, " ") -NoNewline -ForegroundColor White
        }
        Write-Host ($device.State).PadRight($longestDeviceNameLength + $spaceSize, " ") -ForegroundColor White
    }

    Write-Host
}
