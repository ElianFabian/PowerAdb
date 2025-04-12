function Invoke-AdbExpression {

    [OutputType([string])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Command
    )

    Assert-AdbExecution -DeviceId $DeviceId

    if ($DeviceId) {
        $deviceIdArg = " -s '$DeviceId'"
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
