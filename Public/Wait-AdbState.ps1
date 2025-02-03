function Wait-AdbState {

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
        $stateLowercase = $State.ToLower()
        $transportLowercase = $Transport.ToLower()
    }

    process {
        if (-not $DeviceId) {
            if ($PSCmdlet.ShouldProcess("adb wait-for-$transportLowercase-$stateLowercase", "", "Wait-AdbState")) {
                return adb "wait-for-$transportLowercase-$stateLowercase"
            }
            return
        }

        $DeviceId | Invoke-AdbExpression -Command "wait-for-$transportLowercase-$stateLowercase" -Verbose:$VerbosePreference
    }
}
