function Switch-AdbUser {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [int] $Id
    )

    process {
        foreach ($device in $DeviceId) {
            Invoke-AdbExpression -DeviceId $device -Command "shell am switch-user $Id" -Verbose:$VerbosePreference > $null
        }
    }
}
