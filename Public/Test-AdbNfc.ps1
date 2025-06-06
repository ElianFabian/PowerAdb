function Test-AdbNfc {

    [OutputType([bool])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [switch] $IgnoreNfcFeatureCheck
    )

    if (-not $IgnoreNfcFeatureCheck -and -not (Test-AdbFeature -DeviceId $DeviceId -Feature 'android.hardware.nfc' -Verbose:$false)) {
        Write-Error -Message "Device with id '$DeviceId' does not support NFC." -Category InvalidOperation -ErrorAction Stop
    }

    $result = Get-AdbServiceDump -DeviceId $DeviceId -Name 'nfc' | Select-Object -First 1

    switch ($result) {
        'mState=on' { $true }
        'mState=off' { $false }
        default {
            Write-Error "Unkown state: $_"
        }
    }
}
