function Test-CacheValue {

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

    return $PowerAdbCache.ContainsKey($cacheKey)
}
