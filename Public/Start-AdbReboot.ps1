function Start-AdbReboot {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("restart", "recovery", "bootloader")]
        [string] $Type
    )

    Assert-AdbExecution -DeviceId $DeviceId

    $mode = switch ($Type) {
        "restart" { '' }
        "recovery" { ' recovery' }
        "rootloader" { '-bootloader' }
    }

    if ($DeviceId) {
        $deviceIdArg = " -s '$DeviceId'"
    }

    if ($PSCmdlet.ShouldProcess("adb$deviceIdArg reboot$mode", '', 'Start-AdbReboot')) {
        adb -s $DeviceId reboot$mode
    }
}
