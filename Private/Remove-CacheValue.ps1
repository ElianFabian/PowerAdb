function Remove-CacheValue {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [string] $Key,

        [Parameter(ParameterSetName = 'All')]
        [switch] $All
    )

    if (-not $PowerAdbCache) {
        return
    }

    $device = $DeviceId
    if (-not $device) {
        $device = Get-AdbDevice -Verbose:$false
    }

    if ($All) {
        $targetKeys = $PowerAdbCache.Keys | Where-Object { $_.StartsWith("$device`:") }

        foreach ($keyName in $targetKeys) {
            $PowerAdbCache.Remove($keyName)
        }
    }
    else {
        $cacheKey = "$device.$Key"

        $PowerAdbCache.Remove($cacheKey)
    }
}
