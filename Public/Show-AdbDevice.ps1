function Show-AdbDevice {

    $devices = Get-AdbDevice

    Write-Host

    if (-not $devices) {
        Write-Error "There are no available devices right now"
        Write-Host
        return
    }

    $names = [string[]] ($devices | ForEach-Object { Get-AdbDeviceName -DeviceId $_ -Verbose:$false -ErrorAction Ignore })
    if ($names) {
        $longestDeviceNameLength = $names | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    }
    else {
        $longestDeviceNameLength = 5
    }

    $longestIdLength = $devices | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum


    $spaceSize = 5

    $header = "$("DeviceId".PadRight($longestIdLength + $spaceSize, " "))$("Name".PadRight($longestDeviceNameLength + $spaceSize, " "))$("API Level".PadRight($longestDeviceNameLength + $spaceSize, " "))State"
    $header += "`n$("--------".PadRight($longestIdLength + $spaceSize, " "))$("----".PadRight($longestDeviceNameLength + $spaceSize, " "))$("---------".PadRight($longestDeviceNameLength + $spaceSize, " "))-----"

    Write-Host $header -ForegroundColor Green

    $namesEnumerator = $names.GetEnumerator()
    $namesEnumerator.Reset()
    foreach ($id in $devices) {
        $namesEnumerator.MoveNext() > $null
        $deviceName = $namesEnumerator.Current
        if (-not $deviceName) {
            $deviceName = "-"
        }

        Write-Host $id.PadRight($longestIdLength + $spaceSize, " ") -NoNewline -ForegroundColor Cyan
        Write-Host $deviceName.PadRight($longestDeviceNameLength + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false -ErrorAction Ignore
        if (-not $apiLevel) {
            Write-Host "-".PadRight($longestDeviceNameLength + $spaceSize, " ") -NoNewline -ForegroundColor DarkCyan
        }
        else {
            Write-Host $apiLevel.ToString().PadRight($longestDeviceNameLength + $spaceSize, " ") -NoNewline -ForegroundColor White
        }
        Write-Host (Get-AdbDeviceState -DeviceId $id -ErrorAction Ignore).PadRight($longestDeviceNameLength + $spaceSize, " ") -ForegroundColor White
    }

    Write-Host
}
