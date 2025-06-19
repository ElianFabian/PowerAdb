function Get-AdbPackage {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $SerialNumber,

        [ValidateSet('All', 'Disabled', 'Enabled', 'System', 'ThirdParty', 'Apex')]
        [string] $FilterBy = 'All',

        [AllowNull()]
        [object] $UserId
    )

    $paramFilterBy = switch ($FilterBy) {
        'All' { '' }
        'Disabled' { ' -d' }
        'Enabled' { ' -e' }
        'System' { ' -s' }
        'ThirdParty' { ' -3' }
        'Apex' { ' --apex-only' }
    }
    if ($null -ne $UserId) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17 -FeatureName "$($MyInvocation.MyCommand.Name) -UserId"

        $userArg = " --user $UserId"
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm list packages$paramFilterBy$userArg" -Verbose:$VerbosePreference `
    | Out-String -Stream `
    | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
    | ForEach-Object { $_.Replace('package:', '') }
}
