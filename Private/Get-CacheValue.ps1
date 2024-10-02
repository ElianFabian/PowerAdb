function Get-CacheValue {

    #TODO: Get name from calling function and use it as the cache key

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Key
    )

    $cacheKey = "$DeviceId.$Key"

    $cachedValue = $AdbCache[$cacheKey]

    return $cachedValue
}
