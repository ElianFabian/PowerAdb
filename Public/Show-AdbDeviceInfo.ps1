function Show-AdbDeviceInfo {

    $devices = Get-AdbDevice

    Write-Host

    if (-not $devices) {
        Write-Error "There are no available devices right now"
        Write-Host
        return
    }

    $names = $devices | Get-AdbDeviceName
    $longestDeviceName = $names | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $longestIdLength = $devices | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    $spaceSize = 5

    $header = "$("DeviceId".PadRight($longestIdLength + $spaceSize, " "))$("Name".PadRight($longestDeviceName + $spaceSize, " "))API level"
    $header += "`n$("--------".PadRight($longestIdLength + $spaceSize, " "))$("----".PadRight($longestDeviceName + $spaceSize, " "))---------"

    Write-Host $header -ForegroundColor Green

    $namesEnumerator = $names.GetEnumerator()
    foreach ($id in $devices) {
        $namesEnumerator.MoveNext() > $null
        $deviceName = $namesEnumerator.Current
        if (-not $deviceName) {
            Write-Error "Couldn't get device name from device id '$id'"
            return
        }

        Write-Host $id.PadRight($longestIdLength + $spaceSize, " ") -NoNewline -ForegroundColor Cyan
        Write-Host $deviceName.PadRight($longestDeviceName + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        Write-Host $(Get-AdbApiLevel -DeviceId $id)
    }

    Write-Host
}
