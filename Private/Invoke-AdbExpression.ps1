function Invoke-AdbExpression {

    [OutputType([string])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Command,

        [switch] $IgnoreExecutionCheck
    )


    if (-not $IgnoreExecutionCheck) {
        Assert-AdbExecution -DeviceId $DeviceId
    }

    if ($DeviceId) {
        Assert-ValidAdbStringArgument $DeviceId -ArgumentName 'DeviceId'

        # FIXME: '-s' parameter does not support string sanitizing as we do for other string arguments.
        # We should find a way to deal with this, maybe just checking for special characters or something.
        $deviceIdArg = " -s '$DeviceId'"

        ### It's hard to reproduce this issue, but we'll leave this commented out for now.
        # Sometimes when you connect a device it suddenly disconnects.
        # $deviceState = Get-AdbDeviceState -DeviceId $DeviceId -PreventLock -Verbose:$false
        # if ($deviceState -eq 'offline') {
        #     $device = Resolve-AdbDevice -DeviceId $DeviceId
        #     $ipAddress, $port = $device.Split(':')
        #     Write-Warning "Device '$device' is offline"
        #     Write-Information "Connecting to device '$device'"
        #     Connect-AdbDevice -IpAddress $ipAddress -Port $port -Verbose:$true
        #     Write-Information "Connected to device '$device'"
        # }
    }

    $adbCommand = "adb$deviceIdArg $Command"

    if ($PSCmdlet.ShouldProcess($adbCommand, '', 'Invoke-AdbExpression')) {
        try {
            $previousEncoding = [System.Console]::OutputEncoding
            [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

            $errors = @()
            $adbScriptBlock = [scriptblock]::Create("$adbCommand")

            $allowedCommands = [string[]] @(
                'adb'
                'echo'
            )
            $allowedVariables = [string[]] @()
            $allowEnvVars = $false

            $adbScriptBlock.CheckRestrictedLanguage($allowedCommands, $allowedVariables, $allowEnvVars)

            Invoke-Expression "$adbCommand 2>&1" `
            | Repair-OutputRendering `
            | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errors += $_
                    return
                }

                Write-Output $_
            }

            # Exceptions with $ErroView = 'ConciseView' does not show new line characters in error messages.
            # For a more easy-to-ready output consider the following: $ErroView = 'NormalView'
            if ($errors.Count -eq 1) {
                throw [AdbCommandException]::new($errors[0].Exception.Message, $errors[0].Exception, $adbCommand)
            }
            elseif ($errors.Count -gt 1) {
                $errorMessage = $errors.Exception.Message -join "`n"
                throw [AdbCommandException]::new($errorMessage, $adbCommand)
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousEncoding
        }
    }
}



# DeviceId format meaning, we might use this in the future:
# - 47031FDJG000G1 (USB Physical Device)
# - 4ae4faf6 (USB Physical Device)
# - 192.168.1.122:5555 (Wireless Physical Device)
# - adb-ZLCQGUPF7TDENZGM-PjhN0r._adb-tls-connect._tcp (Wireless Physical Device)
# - emulator-5554 (Emulator)
# - localhost:59608 (Remote Device)
