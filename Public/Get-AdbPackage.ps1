function Get-AdbPackage {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId,

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
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17 -FeatureName "$($MyInvocation.MyCommand.Name) -UserId"

        $userArg = " --user $UserId"
    }

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm list packages$paramFilterBy$userArg" -Verbose:$VerbosePreference `
    | Out-String -Stream `
    | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
    | ForEach-Object { $_.Replace('package:', '') }
}
