function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $cache = Get-CacheValue -DeviceId $id -ErrorAction SilentlyContinue
            if ($null -ne $cache) {
                Write-Verbose "Get cached API level: '$cache'"
                [uint32] $cache
            }
            else {
                $apiLevel = Get-AdbProperty -DeviceId $id -Name 'ro.build.version.sdk' -Verbose:$VerbosePreference 2> $null
                Set-CacheValue -DeviceId $id -Value $apiLevel
                [uint32] $apiLevel
            }
        }
    }
}
