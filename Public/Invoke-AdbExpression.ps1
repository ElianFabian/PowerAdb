function Invoke-AdbExpression {

    [OutputType([string[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Command
    )

    begin {
        $availableDevicesCount = (adb devices).Count - 2
        if ($availableDevicesCount -eq 0) {
            Write-Warning "There are no available devices"
            $stopExecution = $true
        }
    }

    process {
        if ($stopExecution) {
            return
        }

        if ($isWindows -and $IsCoreCLR) {
            ResetConsoleColors
        }

        if (-not $PSBoundParameters.ContainsKey('DeviceId')) {
            if ($availableDevicesCount -gt 1) {
                Write-Error "There are multiple devices connected, you have to indicate the device id"
                return
            }
        }

        try {
            $previousEncoding = [System.Console]::OutputEncoding
            [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

            if (-not $DeviceId) {
                $adbCommand = "adb $Command"
                if ($PSCmdlet.ShouldProcess($adbCommand)) {
                    Invoke-Expression $adbCommand
                }
            }
            else {
                foreach ($id in $DeviceId) {
                    $adbCommand = "adb -s $id $Command"
                    if ($PSCmdlet.ShouldProcess($adbCommand)) {
                        Invoke-Expression $adbCommand
                    }
                }
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousEncoding
        }
    }
}



if ($IsWindows -and $IsCoreCLR) {
    $methodDefinitions = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint lpMode);
'@
    $script:Kernel32 = Add-Type -MemberDefinition $methodDefinitions -Name 'Kernel32' -Namespace 'Win32' -PassThru -Verbose:$false
    $script:HConsoleHandle = $script:Kernel32::GetStdHandle(-11) # STD_OUTPUT_HANDLE
    $script:ConsoleMode = 7

    # At some point in some PowerShell Core version for Windows there are problems related to ANSI
    # In our case the first verbose message when looping a collection it looks like '[33;1mVERBOSE'
    # Check this link for hardly more information and the solution used here: https://stackoverflow.com/a/70534568/18418162
    # This function doesn't seem to have any performance overhead
    function ResetConsoleColors {
        $script:Kernel32::SetConsoleMode($script:HConsoleHandle, $script:ConsoleMode) > $null
    }
}
