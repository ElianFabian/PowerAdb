function Wait-AdbState {

    [CmdletBinding()]
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
            return Invoke-AdbExpression -Command "wait-for-$transportLowercase-$stateLowercase" -Verbose:$VerbosePreference
        }

        $DeviceId | Invoke-AdbExpression -Command "wait-for-$transportLowercase-$stateLowercase" -Verbose:$VerbosePreference
    }
}
