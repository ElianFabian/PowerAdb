function Get-CacheValue {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId,

        [string] $FunctionName = (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [string] $Key
    )

    $cacheKey = "$DeviceId`:$FunctionName"
    if ($Key) {
        $cacheKey = "$cacheKey`:$Key"
    }

    $cachedValue = $PowerAdbCache[$cacheKey]

    Write-Verbose "Get cached value for key '$cacheKey'"

    return $cachedValue
}
