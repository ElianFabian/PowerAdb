# It seems that in non-Windows-terminal, the ANSI escape sequences are not interpreted correctly.
# In our case the first verbose message when looping a collection it looks like '[33;1mVERBOSE' (or similar).
# Check this link for more information and the solution used here: https://stackoverflow.com/a/70534568/18418162
# This function impacts performance, but it only needs to be called at the beginning of an iteration.


# From: https://mikefrobbins.com/2024/05/16/detecting-windows-terminal-with-powershell
function TestWindowsTerminal {
    [CmdletBinding()]
    param ()
    # Check if PowerShell version is 5.1 or below, or if running on Windows
    if ($PSVersionTable.PSVersion.Major -gt 5 -and -not $IsWindows) {
        Write-Verbose -Message 'Exiting due to non-Windows environment'
        return $false
    }

    $currentPid = $PID

    # Loop through parent processes to check if Windows Terminal is in the hierarchy
    while ($currentPid) {
        try {
            $process = Get-CimInstance Win32_Process -Filter "ProcessId = $currentPid" -ErrorAction Stop -Verbose:$false
        }
        catch {
            # Return false if unable to get process information
            return $false
        }

        Write-Verbose -Message "ProcessName: $($process.Name), Id: $($process.ProcessId), ParentId: $($process.ParentProcessId)"

        # Check if the current process is Windows Terminal
        if ($process.Name -eq 'WindowsTerminal.exe') {
            return $true
        }
        else {
            # Move to the parent process
            $currentPid = $process.ParentProcessId
        }
    }

    # Return false if Windows Terminal is not found in the hierarchy
    return $false
}



if (-not $IsWindows -or -not $IsCoreCLR -or (TestWindowsTerminal)) {
    function Repair-OutputRendering {

        param (
            [Parameter(ValueFromPipeline)]
            [object] $InputObject
        )

        process {
            # no-op
            $InputObject
        }
    }
    return
}

function Repair-OutputRendering {

    param (
        [Parameter(ValueFromPipeline)]
        [object] $InputObject
    )

    begin {
        $fixApplied = $false
    }

    process {
        if (-not $fixApplied) {
            $fixApplied = $true
            [Win32.Kernel32]::SetConsoleMode($script:HConsoleHandle, $script:ConsoleMode) > $null
        }

        $InputObject
    }
}



if (-not ([System.Management.Automation.PSTypeName]'Win32.Kernel32').Type) {
    $methodDefinitions = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint lpMode);
'@

    Add-Type -MemberDefinition $methodDefinitions -Name 'Kernel32' -Namespace 'Win32' -PassThru -Verbose:$false
}

$script:HConsoleHandle = [Win32.Kernel32]::GetStdHandle(-11) # STD_OUTPUT_HANDLE
$script:ConsoleMode = 7
