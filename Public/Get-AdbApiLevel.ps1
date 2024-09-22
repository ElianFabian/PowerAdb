function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | ForEach-Object {
            $cache = Get-CacheValue -DeviceId $_ -Key 'ApiLevel' -ErrorAction SilentlyContinue
            if ($null -ne $cache) {
                [uint32] $cache
            }
            else {
                $apiLevel = Get-AdbProperty -DeviceId $_ -Name 'ro.build.version.sdk' -QueryFromList -Verbose:$VerbosePreference 2> $null
                Set-CacheValue -DeviceId $_ -Key 'ApiLevel' -Value $apiLevel
                [uint32] $apiLevel
            }
        }
    }
}
