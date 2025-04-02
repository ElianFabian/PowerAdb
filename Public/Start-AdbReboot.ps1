function Start-AdbReboot {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateSet("Restart", "Recovery", "Bootloader")]
        [string] $Type
    )

    begin {
        $mode = switch ($Type) {
            "Restart" { '' }
            "Recovery" { ' recovery' }
            "Bootloader" { '-bootloader' }
        }
    }

    process {
        foreach ($id in $DeviceId) {
            if ($PSCmdlet.ShouldProcess("adb -s $id reboot$mode", '', 'Start-AdbReboot')) {
                adb -s $id reboot$mode
            }
        }
    }
}
