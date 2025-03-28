function Remove-AdbUser {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [int] $Id
    )

    process {
        foreach ($device in $DeviceId) {
            Invoke-AdbExpression -DeviceId $device -Command "shell pm remove-user $Id" -Verbose:$VerbosePreference > $null
        }
    }
}
