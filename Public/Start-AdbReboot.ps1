function Start-AdbReboot {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("restart", "recovery", "bootloader")]
        [string] $Type
    )

    $mode = switch ($Type) {
        "restart" { '' }
        "recovery" { ' recovery' }
        "rootloader" { '-bootloader' }
    }

    Invoke-AdbExpression -Command "reboot$mode" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
