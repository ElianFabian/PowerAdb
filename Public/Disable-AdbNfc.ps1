function Disable-AdbNfc {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [switch] $IgnoreNfcFeatureCheck
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 24

    if (-not $IgnoreNfcFeatureCheck -and -not (Test-AdbFeature -SerialNumber $SerialNumber -Feature 'android.hardware.nfc' -Verbose:$false)) {
        Write-Error -Message "Device with serial number '$SerialNumber' does not support NFC." -Category InvalidOperation -ErrorAction Stop
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell svc nfc disable' -Verbose:$VerbosePreference
}
