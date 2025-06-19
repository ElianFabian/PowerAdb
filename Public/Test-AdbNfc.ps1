function Test-AdbNfc {

    [OutputType([bool])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [switch] $IgnoreNfcFeatureCheck
    )

    if (-not $IgnoreNfcFeatureCheck -and -not (Test-AdbFeature -SerialNumber $SerialNumber -Feature 'android.hardware.nfc' -Verbose:$false)) {
        Write-Error -Message "Device with serial number '$SerialNumber' does not support NFC." -Category InvalidOperation -ErrorAction Stop
    }

    $result = Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'nfc' | Select-Object -First 1

    switch ($result) {
        'mState=on' { $true }
        'mState=off' { $false }
        default {
            Write-Error "Unkown state: $_"
        }
    }
}
