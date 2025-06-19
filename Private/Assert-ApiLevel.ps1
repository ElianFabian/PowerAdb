function Assert-ApiLevel {

    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'LessThanOrEqualTo')]
        [int] $LessThanOrEqualTo,

        [Parameter(Mandatory, ParameterSetName = 'GreaterThanOrEqualTo')]
        [int] $GreaterThanOrEqualTo,

        [Parameter(Mandatory, ParameterSetName = 'EqualTo')]
        [int] $EqualTo,

        [Parameter(Mandatory, ParameterSetName = 'NotEqualTo')]
        [int] $NotEqualTo,

        [Parameter(Mandatory, ParameterSetName = 'Between')]
        [int] $From,

        [Parameter(Mandatory, ParameterSetName = 'Between')]
        [int] $To,

        [string] $FeatureName = (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [string] $ExtraInfo
    )

    $serial = Resolve-AdbDevice -SerialNumber $SerialNumber

    $apiLevel = Get-AdbApiLevel -SerialNumber $serial -Verbose:$false

    if ($ExtraInfo) {
        $extraInfoMessage = " $ExtraInfo"
    }

    switch ($PSCmdlet.ParameterSetName) {
        'LessThanOrEqualTo' {
            if (-not ($apiLevel -le $LessThanOrEqualTo)) {
                throw [ApiLevelException]::new("Device with serial number '$serial' and API level $apiLevel is not supported. '$FeatureName' requires API level less than $LessThanOrEqualTo.$extraInfoMessage")
            }
        }
        'GreaterThanOrEqualTo' {
            if (-not ($apiLevel -ge $GreaterThanOrEqualTo)) {
                throw [ApiLevelException]::new("Device with serial number '$serial' and API level $apiLevel is not supported. '$FeatureName' requires API level greater than $GreaterThanOrEqualTo or above.$extraInfoMessage")
            }
        }
        'EqualTo' {
            if (-not ($apiLevel -eq $EqualTo)) {
                throw [ApiLevelException]::new("Device with serial number '$serial' and API level $apiLevel is not supported. '$FeatureName' requires API level equal to $EqualTo.$extraInfoMessage")
            }
        }
        'NotEqualTo' {
            if (-not ($apiLevel -ne $NotEqualTo)) {
                throw [ApiLevelException]::new("Device with serial number '$serial' and API level $apiLevel is not supported. '$FeatureName' requires API level not equal to $EqualTo.$extraInfoMessage")
            }
        }
        'Between' {
            if (-not ($From -le $apiLevel -and $apiLevel -le $To)) {
                throw [ApiLevelException]::new("Device with serial number '$serial' and API level $apiLevel is not supported. '$FeatureName' requires API level between $From and $To.$extraInfoMessage")
            }
        }
    }
}
