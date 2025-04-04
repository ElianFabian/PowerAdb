function Remove-CacheValue {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [string] $Key,

        [Parameter(ParameterSetName = 'All')]
        [switch] $All
    )

    if ($All) {
        $targetKeys = $PowerAdbCache.Keys | Where-Object { $_.StartsWith("$DeviceId`:") }

        foreach ($keyName in $targetKeys) {
            $PowerAdbCache.Remove($keyName)
        }
    }
    else {
        $cacheKey = "$DeviceId.$Key"

        $PowerAdbCache.Remove($cacheKey)
    }
}
