function Get-AdbBatteryInfo {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $infoMatches = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Out-String `
            | Select-String -Pattern $batteryPattern -AllMatches `
            | Select-Object -ExpandProperty Matches -First 1

            $groups = $infoMatches.Groups

            $batteryInfo = [PSCustomObject]@{
                DeviceId    = $id
                AcPowered   = [bool] $groups['acPowered'].Value
                UsbPowered  = [bool] $groups['usbPowered'].Value
                Status      = [int] $groups['status'].Value
                Health      = [int] $groups['health'].Value
                Present     = [bool] $groups['present'].Value
                Level       = [int] $groups['level'].Value
                Scale       = [int] $groups['scale'].Value
                Voltage     = [float] ([int] $groups['voltage'].Value) / 1000.0
                Temperature = ([int] $groups['temperature'].Value) / 10
                Technology  = $groups['technology'].Value
            }

            $batteryInfo | Add-Member -MemberType ScriptProperty -Name StatusName -Value {
                switch ($this.Status) {
                    1 { "Unknown" }
                    2 { "Charging" }
                    3 { "Discharging" }
                    4 { "NotCharging" }
                    5 { "Full" }
                    default { "UnknownStatus-$($this.Status)" }
                }
            }
            $batteryInfo | Add-Member -MemberType ScriptProperty -Name HealthName -Value {
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

            $wirelessPowered = $groups['wirelessPowered']
            if ($wirelessPowered) {
                $batteryInfo | Add-Member -MemberType NoteProperty -Name WirelessPowered -Value ([bool] $wirelessPowered.Value)
            }

            $dockPowered = $groups['dockPowered']
            if ($dockPowered) {
                $batteryInfo | Add-Member -MemberType NoteProperty -Name DockPowered -Value ([bool] $dockPowered.Value)
            }

            $maxChargingCurrent = $groups['maxChargingCurrent']
            if ($maxChargingCurrent) {
                $batteryInfo | Add-Member -MemberType NoteProperty -Name MaxChargingCurrent -Value ([int] $maxChargingCurrent.Value)
            }

            $maxChargingVoltage = $groups['maxChargingVoltage']
            if ($maxChargingVoltage) {
                $batteryInfo | Add-Member -MemberType NoteProperty -Name MaxChargingVoltage -Value ([int] $maxChargingVoltage.Value)
            }

            $batteryInfo
        }
    }
}



$script:batteryPattern = @"
AC powered:\s*(?<acPowered>true|false)(\r?\n)+
\s*USB powered:\s*(?<usbPowered>true|false)(\r?\n)+
(
\s*Wireless powered:\s*(?<wirelessPowered>true|false)(\r?\n)+
)?
(
\s*Dock powered:\s*(?<dockPowered>true|false)(\r?\n)+
)?
(
\s*Max charging current:\s*(?<maxChargingCurrent>\d+)(\r?\n)+
)?
(
\s*Max charging voltage:\s*(?<maxChargingVoltage>\d+)(\r?\n)+
)?
(
\s*Charge counter:\s*(?<chargeCounter>\d+)(\r?\n)+
)?
\s*status:\s*(?<status>\d+)(\r?\n)+
\s*health:\s*(?<health>\d+)(\r?\n)+
\s*present:\s*(?<present>true|false)(\r?\n)+
\s*level:\s*(?<level>\d+)(\r?\n)+
\s*scale:\s*(?<scale>\d+)(\r?\n)+
\s*voltage:\s*(?<voltage>\d+)(\r?\n)+
\s*temperature:\s*(?<temperature>\d+)(\r?\n)+
\s*technology:\s*(?<technology>.+)
"@.Replace("`r`n", "").Replace("`n", "")
