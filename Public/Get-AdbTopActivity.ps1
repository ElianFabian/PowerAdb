function Get-AdbTopActivity {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell dumpsys activity activities" -Verbose:$VerbosePreference
        | Select-String -Pattern "topResumedActivity=.+{.+ .+ (.+) .+}" -AllMatches
        | ForEach-Object { $_.Matches[0].Groups[1].Value.Replace('/', '') }
    }
}
