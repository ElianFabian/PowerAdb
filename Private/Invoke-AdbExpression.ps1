function Invoke-AdbExpression {

    [OutputType([string])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Command,

        [switch] $IgnoreExecutionCheck
    )


    # NOTES: In some devices (e.g. Pixel 8 Pro API 35) when they're connected via Wi-Fi, even they're in the 'device' state,
    # the commands freeze until the screen is turned on.
    # It would be cool to find a way to detect this and turn the screen on automatically
    # or at least warn the user about it.
    # Sometimes even turning on the screen the commands block.

    if (-not $IgnoreExecutionCheck) {
        Assert-AdbExecution -SerialNumber $SerialNumber
    }

    if ($SerialNumber) {
        Assert-ValidAdbStringArgument $SerialNumber -ArgumentName 'SerialNumber'

        # FIXME: '-s' parameter does not support string sanitizing as we do for other string arguments.
        # We should find a way to deal with this, maybe just checking for special characters or something.
        $serialNumberArg = " -s '$SerialNumber'"

        ### It's hard to reproduce this issue, but we'll leave this commented out for now.
        # Sometimes when you connect a device it suddenly disconnects.
        # $deviceState = Get-AdbDeviceState -SerialNumber $SerialNumber -PreventLock -Verbose:$false
        # if ($deviceState -eq 'offline') {
        #     $serial = Resolve-AdbDevice -SerialNumber $SerialNumber
        #     $ipAddress, $port = $serial.Split(':')
        #     Write-Warning "Device '$serial' is offline"
        #     Write-Information "Connecting to device '$serial'"
        #     Connect-AdbDevice -IpAddress $ipAddress -Port $port -Verbose:$true
        #     Write-Information "Connected to device '$serial'"
        # }
    }

    $adbCommand = "adb$serialNumberArg $Command"

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



# Serial number format meaning, we might use this in the future:
# - 47031FDJG000G1 (USB Physical Device)
# - 4ae4faf6 (USB Physical Device)
# - 192.168.1.122:5555 (Wireless Physical Device)
# - adb-ZLCQGUPF7TDENZGM-PjhN0r._adb-tls-connect._tcp (Wireless Physical Device)
# - emulator-5554 (Emulator)
# - localhost:59608 (Remote Device, BlueStacks (or similar))
