function Wait-AdbBluetoothState {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [ValidateSet('On', 'Off')]
        [Parameter(Mandatory)]
        [string] $State,

        [switch] $ForceWait
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 34

    $stateCode = switch ($State) {
        'On' { 'STATE_ON' }
        'Off' { 'STATE_OFF' }
    }

    do {
        try {
            $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell cmd bluetooth_manager wait-for-state:$stateCode" -Verbose:$VerbosePreference | Select-Object -Last 1
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
