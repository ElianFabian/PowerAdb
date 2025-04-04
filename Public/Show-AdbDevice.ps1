function Show-AdbDevice {

    $devices = Get-AdbDevice

    Write-Host

    if (-not $devices) {
        Write-Error "There are no available devices right now"
        Write-Host
        return
    }

    $names = [string[]] ($devices | Get-AdbDeviceName)
    if (-not $names) {
        Write-Error "Couldn't get device names"
        return
    }

    $longestDeviceName = $names | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $longestIdLength = $devices | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    $spaceSize = 5

    $header = "$("DeviceId".PadRight($longestIdLength + $spaceSize, " "))$("Name".PadRight($longestDeviceName + $spaceSize, " "))$("API Level".PadRight($longestDeviceName + $spaceSize, " "))State"
    $header += "`n$("--------".PadRight($longestIdLength + $spaceSize, " "))$("----".PadRight($longestDeviceName + $spaceSize, " "))$("---------".PadRight($longestDeviceName + $spaceSize, " "))-----"

    Write-Host $header -ForegroundColor Green

    $namesEnumerator = $names.GetEnumerator()
    $namesEnumerator.Reset()
    foreach ($id in $devices) {
        $namesEnumerator.MoveNext() > $null
        $deviceName = $namesEnumerator.Current
        if (-not $deviceName) {
            $deviceName = "Unknown"
        }

        Write-Host $id.PadRight($longestIdLength + $spaceSize, " ") -NoNewline -ForegroundColor Cyan
        Write-Host $deviceName.PadRight($longestDeviceName + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
        if (-not $apiLevel) {
            Write-Host "Unknown".PadRight($longestDeviceName + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        } else {
            Write-Host $apiLevel.ToString().PadRight($longestDeviceName + $spaceSize, " ") -NoNewline -ForegroundColor White
        }
        Write-Host (Get-AdbState -DeviceId $id).PadRight($longestDeviceName + $spaceSize, " ") -ForegroundColor White
    }

    Write-Host
}
