function Test-CacheValue {

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

    return $PowerAdbCache.ContainsKey($cacheKey)
}
