function Remove-CacheValue {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [string] $Key,

        [Parameter(ParameterSetName = 'All')]
        [switch] $All
    )

    if ($All) {
        $targetKeys = $AdbCache.Keys | Where-Object { $_.StartsWith("$DeviceId.") }

        foreach ($keyName in $targetKeys) {
            $AdbCache.Remove($keyName)
        }
    }
    else {
        $cacheKey = "$DeviceId.$Key"

        $AdbCache.Remove($cacheKey)
    }
}
