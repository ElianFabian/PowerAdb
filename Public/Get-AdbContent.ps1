function Get-AdbContent {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [switch] $Raw
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell cat '$RemotePath'" -Verbose:$VerbosePreference | Out-String -Stream:(-not $Raw)
        }
    }
}
