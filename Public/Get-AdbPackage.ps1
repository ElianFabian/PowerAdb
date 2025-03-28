function Get-AdbPackage {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateSet('All', 'Disabled', 'Enabled', 'System', 'ThirdParty', 'Apex')]
        [string] $FilterBy = 'All',

        [AllowNull()]
        [Nullable[uint32]] $UserId
    )

    begin {
        $paramFilterBy = switch ($FilterBy) {
            'All' { '' }
            'Disabled' { ' -d' }
            'Enabled' { ' -e' }
            'System' { ' -s' }
            'ThirdParty' { ' -3' }
            'Apex' { ' --apex-only' }
        }
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
    }

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list packages$paramFilterBy$userArg" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
        | Out-String -Stream `
        | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
        | ForEach-Object { $_.Replace('package:', '') }
    }
}
