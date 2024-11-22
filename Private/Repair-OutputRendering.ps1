# It seems that in some Windows Computers with PowerShell Core there are problems related to ANSI.
# In our case the first verbose message when looping a collection it looks like '[33;1mVERBOSE' (or similar).
# Check this link for hardly more information and the solution used here: https://stackoverflow.com/a/70534568/18418162
# This function impacts performance, but it's the only way I know to fix the issue.
# It would be nice to somehow detect what computers have this issue and only run this function on them (maybe it's on Windows 10 computers).

if (-not $IsWindows -or -not $IsCoreCLR) {
    function Repair-OutputRendering {
        # no-op
    }
    return
}

function Repair-OutputRendering {
    [Win32.Kernel32]::SetConsoleMode($script:HConsoleHandle, $script:ConsoleMode) > $null
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
