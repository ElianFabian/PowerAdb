function Get-AdbBatteryInfo {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $output = [PSCustomObject]@{}

    Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'battery' -Verbose:$VerbosePreference `
    | Select-Object -Skip 1 `
    | Where-Object { $_ } `
    | ForEach-Object {
        $rawName, $rawValue = $_ -split ':'

        $name = ConvertTo-PascalCase $rawName.Trim()
        $value = if ($rawValue -match '\d+') {
            [int] $rawValue
        }
        elseif ($rawValue -match '(true|false)') {
            [bool] $rawValue
        }
        else {
            $rawValue.Trim()
        }

        $output | Add-Member -MemberType NoteProperty -Name $name -Value $value
    }

    $output | Add-Member -MemberType ScriptProperty -Name StatusName -Value {
        switch ($this.Status) {
            1 { "Unknown" }
            2 { "Charging" }
            3 { "Discharging" }
            4 { "NotCharging" }
            5 { "Full" }
            default { "UnknownStatus-$($this.Status)" }
        }
    }
    $output | Add-Member -MemberType ScriptProperty -Name HealthName -Value {
        switch ($this.Health) {
            1 { "Unknown" }
            2 { "Good" }
            3 { "Overheated" }
            4 { "Dead" }
            5 { "Overvoltage" }
            6 { "Failed" }
            7 { "Cold" }
            default { "UnknownHealth-$($this.Health)" }
        }
    }

    return $output
}
