function Get-AdbForegroundApplicationId {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            if (-not (Test-AdbEmulator -DeviceId $id)) {
                # Concluded from experience results
                Write-Error "Can't get foreground application in real device. Device id: '$id'"
                continue
            }
        }
        $DeviceId | Invoke-AdbExpression -Command "shell dumpsys window windows" -Verbose:$VerbosePreference
        | Select-String -Pattern "mCurrentFocus=.+ u0 (.+)/" -AllMatches
        | Select-Object -ExpandProperty Matches
        | ForEach-Object { $_.Groups[1].Value }
    }
}
