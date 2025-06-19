function Get-CacheValue {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [string] $FunctionName = (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [string] $Key
    )

    if (-not $PowerAdbCache) {
        return
    }

    $serial = $SerialNumber
    if (-not $serial) {
        $serial = Get-AdbDevice -Verbose:$false
    }

    $cacheKey = "$serial`:$FunctionName"
    if ($Key) {
        $cacheKey = "$cacheKey`:$Key"
    }

    $cachedValue = $PowerAdbCache[$cacheKey]

    Write-Verbose "Get cached value for key '$cacheKey'"

    return $cachedValue
}
