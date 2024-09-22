function Get-CacheValue {

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
