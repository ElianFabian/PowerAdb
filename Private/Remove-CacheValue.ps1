function Remove-CacheValue {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [string] $Key,

        [Parameter(ParameterSetName = 'All')]
        [switch] $All
    )

    if (-not $PowerAdbCache) {
        return
    }

    $serial = $SerialNumber
    if (-not $serial) {
        $serial = Get-AdbDevice -Verbose:$false
    }

    if ($All) {
        $targetKeys = $PowerAdbCache.Keys | Where-Object { $_.StartsWith("$serial`:") }

        foreach ($keyName in $targetKeys) {
            $PowerAdbCache.Remove($keyName)
        }
    }
    else {
        $cacheKey = "$serial.$Key"

        $PowerAdbCache.Remove($cacheKey)
    }
}
