function Get-AdbChildItem {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell ls '$RemotePath'" -Verbose:$VerbosePreference `
            | Out-String -Stream `
            | Where-Object { -not $_.Contains(':') -and -not [string]::IsNullOrWhiteSpace($_) }
        }
    }
}
