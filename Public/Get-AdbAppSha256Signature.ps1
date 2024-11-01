function Get-AdbAppSha256Signature {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
                | Select-String -Pattern "Signatures: \[(.+)\]" `
                | Select-Object -ExpandProperty Matches -First 1 `
                | ForEach-Object { $_.Groups[1].Value }
            }
        }
    }
}

# This function doesn't seem to work on real devices, only on emulators
