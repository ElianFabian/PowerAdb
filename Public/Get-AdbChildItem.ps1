function Get-AdbChildItem {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [string] $RemotePath,

        [switch] $Recurse,

        [string] $RunAs
    )

    begin {
        if ($Recurse) {
            $paramRecurse = " -R"
        }
        if ($RunAs) {
           $runAsCommand = " run-as '$RunAs'"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell $runAsCommand ls$paramRecurse '$RemotePath'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Out-String -Stream `
            | Where-Object { -not $_.Contains(':') -and -not [string]::IsNullOrWhiteSpace($_) }
        }
    }
}
