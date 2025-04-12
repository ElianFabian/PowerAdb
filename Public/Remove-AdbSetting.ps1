function Remove-AdbSetting {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("global", "system", "secure")]
        [string] $Namespace,

        [Parameter(Mandatory)]
        [string[]] $Key
    )

    $Key = [string] $PSBoundParameters['Key']
    if ($Key.Contains(" ")) {
        Write-Error "Key '$Key' can't contain space characters"
        return
    }

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 21

    foreach ($k in $Key) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell settings delete $Namespace '$k'" -Verbose:$VerbosePreference
    }
}
