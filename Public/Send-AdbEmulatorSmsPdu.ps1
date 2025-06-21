function Send-AdbEmulatorSmsPdu {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Data
    )

    if ($Data.Length -lt 16) {
        Write-Host "Data minimum length is 16, but was $($Data.Length)." -ErrorAction Stop
    }
    if ($Data.Length % 2 -ne 0) {
        Write-Host "Data length must be even, but was $($Data.Length)." -ErrorAction Stop
    }
    if ($Data -notmatch '^(?:[0-9A-Fa-f]{2})+$') {
        Write-Host "Data must be an hex string, but was $($Data.Length)." -ErrorAction Stop
    }

    Invoke-EmuExpression -SerialNumber $SerialNumber -Command "sms pdu '$Data'" -Verbose:$VerbosePreference
}
