function Wait-AdbBluetoothState {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [ValidateSet('On', 'Off')]
        [Parameter(Mandatory)]
        [string] $State,

        [switch] $ForceWait,

        [switch] $IgnoreBluetoothFeatureCheck
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 34

    if (-not $IgnoreBluetoothFeatureCheck -and -not (Test-AdbFeature -SerialNumber $SerialNumber -Feature 'android.hardware.bluetooth' -Verbose:$false)) {
        Write-Error -Message "Device with serial number '$SerialNumber' does not support Bluetooth." -Category InvalidOperation -ErrorAction Stop
    }

    $stateCode = switch ($State) {
        'On' { 'STATE_ON' }
        'Off' { 'STATE_OFF' }
    }

    do {
        try {
            $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd bluetooth_manager wait-for-state:$stateCode" -Verbose:$VerbosePreference | Select-Object -Last 1
        }
        catch {
            if (-not $ForceWait) {
                if ($_.Exception.Message.Contains("BluetoothShellCommand: wait-for-state:$stateCode`: Failed with status=-1")) {
                    throw [System.TimeoutException]::new($_.Exception.Message)
                }
            }
        }
    }
    while ($ForceWait -and $result -ne "wait-for-state:$stateCode`: Success")
}
