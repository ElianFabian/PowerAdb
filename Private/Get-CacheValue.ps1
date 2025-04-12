function Get-CacheValue {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [string] $FunctionName = (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [string] $Key
    )

    if (-not $PowerAdbCache) {
        return
    }

    $device = $DeviceId
    if (-not $device) {
        $device = Get-AdbDevice -Verbose:$false
    }

    $cacheKey = "$device`:$FunctionName"
    if ($Key) {
        $cacheKey = "$cacheKey`:$Key"
    }

    $cachedValue = $PowerAdbCache[$cacheKey]

    Write-Verbose "Get cached value for key '$cacheKey'"

    return $cachedValue
}
