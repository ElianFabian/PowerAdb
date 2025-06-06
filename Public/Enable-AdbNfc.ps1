function Enable-AdbNfc {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [switch] $IgnoreNfcFeatureCheck
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 24

    if (-not $IgnoreNfcFeatureCheck -and -not (Test-AdbFeature -DeviceId $DeviceId -Feature 'android.hardware.nfc' -Verbose:$false)) {
        Write-Error -Message "Device with id '$DeviceId' does not support NFC." -Category InvalidOperation -ErrorAction Stop
    }

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell svc nfc enable' -Verbose:$VerbosePreference
}
