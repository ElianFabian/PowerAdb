function Assert-ValidIntent {

    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    if ($Intent.IgnoredUnsupportedFeatures) {
        return
    }

    $device = Resolve-AdbDevice -DeviceId $DeviceId

    $typesApi20 = @(
        'StringArray'
    )
    $typesApi23 = @(
        'IntArray'
        'IntArrayList'
        'LongArray'
        'LongArrayList'
        'FloatArray'
        'FloatArrayList'
        'StringArrayList'
    )
    $typesApi33 = @(
        'Double'
        'DoubleArray'
        'DoubleArrayList'
    )

    if ($Intent.Extras) {
        $extras = $Intent.Extras.Invoke()
    }

    foreach ($extra in $extras) {
        $type = $extra.Type

        if ($type -in $typesApi20) {
            Assert-ApiLevel -DeviceId $device -GreaterThanOrEqualTo 20 -FeatureName "Intent: $type type in extras"
        }
        elseif ($type -in $typesApi23) {
            Assert-ApiLevel -DeviceId $device -GreaterThanOrEqualTo 23 -FeatureName "Intent: $type type in extras"
        }
        elseif ($type -in $typesApi33) {
            Assert-ApiLevel -DeviceId $device -GreaterThanOrEqualTo 33 -FeatureName "Intent: $type type in extras"
        }
    }

    if ($Intent.Identifier) {
        Assert-ApiLevel -DeviceId $device -GreaterThanOrEqualTo 29 -FeatureName "Intent: Identifier"
    }

    $apiLevel = Get-AdbApiLevel -DeviceId $device -Verbose:$false

    if ($Intent.NamedFlags) {
        $flagNames = $Intent.NamedFlags
        $validFlagNames = Get-IntentNamedFlag -ApiLevel $apiLevel

        foreach ($flagName in $flagNames) {
            if ($flagName -notin $validFlagNames) {
                throw [System.NotSupportedException]::new("Operation not supported for device with id $device and API level $apiLevel. 'Intent: Flag <$flagName>' is not supported. These are the valid flags: [$($validFlagNames -join ', ')]")
            }
        }
    }
}
