function Wait-AdbDeviceState {

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string[]])]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("Device", "Recovery", "Rescue", "Sideload", "Bootloader", "Disconnect")]
        [string] $State,

        [ValidateSet("Usb", "Local", "Any")]
        [string] $Transport = "Any"
    )

    begin {
        $stateLowercase = switch ($State) {
            "Device" { "device" }
            "Recovery" { "recovery" }
            "Rescue" { "rescue" }
            "Sideload" { "sideload" }
            "Bootloader" { "bootloader" }
            "Disconnect" { "disconnect" }
        }
        $transportLowercase = switch ($Transport) {
            "Usb" { "usb" }
            "Local" { "local" }
            "Any" { "any" }
        }
    }

    process {
        if (-not $DeviceId) {
            Invoke-AdbExpression -Command "wait-for-$transportLowercase-$stateLowercase" -Verbose:$VerbosePreference
            return
        }
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "wait-for-$transportLowercase-$stateLowercase" -Verbose:$VerbosePreference
        }
    }
}
