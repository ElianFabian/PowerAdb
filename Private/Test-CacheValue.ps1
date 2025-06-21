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

    $serial = Resolve-AdbDevice -SerialNumber $SerialNumber
    if (-not $serial) {
        Write-Error "No device is connected or available to set cache value." -ErrorAction Stop
    }

    $cacheKey = "$serial`:$FunctionName"
    if ($Key) {
        $cacheKey = "$cacheKey`:$Key"
    }

    return $PowerAdbCache.ContainsKey($cacheKey)
}
