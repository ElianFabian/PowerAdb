function Get-CacheValue {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId,

        [string] $Key = (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command)
    )

    $cacheKey = "$DeviceId.$Key"

    $cachedValue = $PowerAdbCache[$cacheKey]

    return $cachedValue
}
