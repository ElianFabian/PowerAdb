function Get-CacheValue {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [string] $Key = (Get-PSCallStack | Select-Object -Skip 1 | Select-Object -First 1 -ExpandProperty Command)
    )

    $cacheKey = "$DeviceId.$Key"

    $cachedValue = $AdbCache[$cacheKey]

    return $cachedValue
}
