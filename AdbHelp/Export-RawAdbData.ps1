param(
    [Parameter(Mandatory = $false)]
    [double]$MinApi = 16,

    [Parameter(Mandatory = $false)]
    [double]$MaxApi = 37.1,

    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = ".raw-adb-help",

    [Parameter(Mandatory = $false)]
    [string]$OllamaModel = "qwen2.5:14b",

    [Parameter(Mandatory = $false)]
    [string]$OllamaUri = "http://localhost:11434/api/generate",

    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "AdbCommands.json",

    [Parameter(Mandatory = $false)]
    [switch]$SkipExisting
)

# Resolve OutputFolder to absolute path
if (-not [System.IO.Path]::IsPathRooted($OutputFolder)) {
    if ($PSScriptRoot) {
        $OutputFolder = Join-Path $PSScriptRoot $OutputFolder
    } else {
        $OutputFolder = Join-Path (Get-Location) $OutputFolder
    }
}
$OutputFolder = [System.IO.Path]::GetFullPath($OutputFolder)

# Resolve ConfigPath to absolute path
if (-not [System.IO.Path]::IsPathRooted($ConfigPath)) {
    if ($PSScriptRoot) {
        $ConfigPath = Join-Path $PSScriptRoot $ConfigPath
    } else {
        $ConfigPath = Join-Path (Get-Location) $ConfigPath
    }
}
$ConfigPath = [System.IO.Path]::GetFullPath($ConfigPath)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "VERBOSE" { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Remove-LeadingEmptyLines {
    param($InputLines)
    if (-not $InputLines) { return @() }
    $arr = @($InputLines)
    while ($arr.Count -gt 0 -and [string]::IsNullOrWhiteSpace($arr[0])) {
        if ($arr.Count -eq 1) { $arr = @(); break }
        $arr = $arr[1..($arr.Count - 1)]
    }
    return $arr
}

function Invoke-Adb {
    param(
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 30
    )
    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()
    try {
        $proc = Start-Process -FilePath "adb" -ArgumentList $Arguments -NoNewWindow -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile -PassThru
        $completed = $proc.WaitForExit($TimeoutSeconds * 1000)
        if (-not $completed) {
            try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch {}
            return @()
        }

        $lines = @()
        if (Test-Path $stdoutFile) {
            $outContent = Get-Content $stdoutFile -ErrorAction SilentlyContinue
            if ($outContent) { $lines += $outContent }
        }
        if (Test-Path $stderrFile) {
            $errContent = Get-Content $stderrFile -ErrorAction SilentlyContinue
            if ($errContent) { $lines += $errContent }
        }
        return (Remove-LeadingEmptyLines $lines)
    } catch {
        return @()
    } finally {
        Remove-Item $stdoutFile, $stderrFile -Force -ErrorAction SilentlyContinue
    }
}

function Stop-Emulator {
    param(
        [string]$Serial,
        $EmuProcess
    )
    if ($Serial) {
        Invoke-Adb -Arguments @("-s", $Serial, "emu", "kill") -TimeoutSeconds 3 | Out-Null
    }
    if ($EmuProcess -and -not $EmuProcess.HasExited) {
        try { Stop-Process -Id $EmuProcess.Id -Force -ErrorAction SilentlyContinue } catch {}
    }
    Get-Process -Name "*emulator*", "*qemu-system*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

function Get-ApiLevelFromName {
    param([string]$AvdName)
    if ($AvdName -match 'API_(\d+(?:\.\d+)?)') {
        if ([double]::TryParse($matches[1], [ref]$null)) {
            return [double]$matches[1]
        }
    }
    return $null
}

function Get-ApiLevelFromOllama {
    param([string]$AvdName, [string]$Model, [string]$Uri)
    Write-Log "Querying Ollama ($Model) for AVD name: '$AvdName'..." "VERBOSE"

    $prompt = 'Extract the exact Android API level number (e.g. 16, 21, 28, 30, 33, 34, 35, 36.0, 36.1, 37.0, 37.1) from the AVD name: "' + $AvdName + '". Return ONLY the numerical API level as a string preserving decimals, with no extra text or markdown formatting.'

    $body = @{
        model  = $Model
        prompt = $prompt
        stream = $false
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $Uri -Method Post -Body $body -ContentType "application/json" -TimeoutSec 30
        $apiStr = $response.response.Trim()
        $apiStr = $apiStr -replace '[^\d\.]', ''
        if ([double]::TryParse($apiStr, [ref]$null)) {
            return [double]$apiStr
        } else {
            return $null
        }
    } catch {
        return $null
    }
}

function Get-AllApiLevelsFromOllama {
    param([string[]]$AvdNames, [string]$Model, [string]$Uri)
    $results = @()
    foreach ($avd in $AvdNames) {
        $results += [PSCustomObject]@{
            name     = $avd
            apiLevel = (Get-ApiLevelFromName -AvdName $avd)
        }
    }
    return $results
}

function Update-AdbCommandsJson {
    param([string]$JsonPath, [string]$CommandType, [string]$CommandName, [string]$HelpArg)
    if (-not (Test-Path $JsonPath)) {
        [PSCustomObject]@{ commands = @() } | ConvertTo-Json -Depth 10 | Out-File -FilePath $JsonPath -Encoding utf8
    }
    try {
        $jsonContent = Get-Content $JsonPath -Raw | ConvertFrom-Json
        if (-not $jsonContent.commands) {
            $jsonContent = [PSCustomObject]@{ commands = @() }
        }
        $found = $false
        foreach ($cmd in $jsonContent.commands) {
            if ($cmd.type -eq $CommandType -and $cmd.name -eq $CommandName) {
                $found = $true
                if ($cmd.helpArg -eq "" -and $HelpArg -ne "") {
                    $cmd.helpArg = $HelpArg
                }
                break
            }
        }
        if (-not $found) {
            $newCmd = [PSCustomObject]@{
                type    = $CommandType
                name    = $CommandName
                helpArg = $HelpArg
            }
            $jsonContent.commands += $newCmd
            $jsonContent.commands = @($jsonContent.commands | Sort-Object type, name)
        }
        $jsonContent | ConvertTo-Json -Depth 10 | Out-File -FilePath $JsonPath -Encoding utf8
    } catch {
        Write-Log "Error updating JSON config" "WARNING"
    }
}

# 1. Check prerequisites
if (-not (Test-Path $ConfigPath)) {
    Write-Log "Configuration file not found at: $ConfigPath" "ERROR"
    exit 1
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

# 2. Get existing AVDs
Write-Log "Checking existing Android Virtual Devices (AVDs)..." "INFO"
$oldEap = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $rawAvdOutput = & emulator -list-avds 2>&1
    $avdListOutput = @()
    foreach ($item in $rawAvdOutput) {
        if ($null -ne $item) { $avdListOutput += "$item" }
    }
} finally {
        $ErrorActionPreference = $oldEap
}
if ($LASTEXITCODE -ne 0 -and -not $avdListOutput) {
    Write-Log "Failed to list AVDs using 'emulator -list-avds'. Ensure Android SDK tools are in PATH." "ERROR"
    exit 1
}

$avds = @($avdListOutput) | Where-Object { $_ -and $_.Trim() -ne "" }
if ($avds.Count -eq 0) {
    Write-Log "No AVDs found." "WARNING"
    exit 0
}

Write-Log "Found $($avds.Count) AVD(s): $($avds -join ', ')" "INFO"

# 3. Map AVDs to API levels using robust local parsing (with Ollama fallback) and filter by range
Write-Log "Discovered AVD mapping results (Range: $MinApi - $MaxApi):" "INFO"
$targetAvds = @()
foreach ($avd in $avds) {
    $apiLevel = Get-ApiLevelFromName -AvdName $avd
    if ($null -eq $apiLevel) {
        $apiLevel = Get-ApiLevelFromOllama -AvdName $avd -Model $OllamaModel -Uri $OllamaUri
    }

    $inRange = ($null -ne $apiLevel -and $apiLevel -ge $MinApi -and $apiLevel -le $MaxApi)
    $statusStr = if ($inRange) { "IN RANGE (Selected)" } else { "OUT OF RANGE / SKIPPED" }
    Write-Log "  - AVD: '$avd' => API Level: $(if($apiLevel){$apiLevel}else{'Unknown'}) [$statusStr]" "VERBOSE"

    if ($inRange) {
        $targetAvds += [PSCustomObject]@{
            Name     = $avd
            ApiLevel = $apiLevel
        }
    }
}

$targetAvds = @($targetAvds | Sort-Object ApiLevel)

if ($targetAvds.Count -eq 0) {
    Write-Log "No AVDs match the specified API range [$MinApi - $MaxApi]." "WARNING"
    exit 0
}

Write-Log "Target AVDs count selected for processing: $($targetAvds.Count)" "SUCCESS"

# Ensure output root directory exists
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

# 4. Loop through target AVDs
foreach ($target in $targetAvds) {
    $avdName = $target.Name
    $apiLevel = $target.ApiLevel
    $apiFolder = Join-Path $OutputFolder "$apiLevel"

    if ($SkipExisting) {
        $checkFile = Join-Path $apiFolder "shell\dumpsys.txt"
        if ((Test-Path $checkFile) -and ((Get-Item $checkFile).Length -gt 0)) {
            Write-Log "Raw ADB data for API $apiLevel already exists at $apiFolder. Skipping (-SkipExisting)..." "SUCCESS"
            continue
        }
    }

    Write-Log "==================================================" "INFO"
    Write-Log "Processing AVD: $avdName (API Level: $apiLevel)" "INFO"
    Write-Log "==================================================" "INFO"

    # Ensure any previous/lingering emulators are shut down before starting a new one
    $activeEmus = @(Invoke-Adb -Arguments @("devices")) | Where-Object { $_ -match 'emulator-\d+' }
    if ($activeEmus.Count -gt 0) {
        foreach ($line in $activeEmus) {
            if ($line -match '^(emulator-\d+)') {
                $existingSerial = $matches[1]
                Write-Log "Shutting down lingering emulator $existingSerial..." "VERBOSE"
            }
        }
        Stop-Emulator
    }
    Start-Sleep -Seconds 3

    # Create subdirectories
    $shellDir = Join-Path $apiFolder "shell"
    $execOutDir = Join-Path $apiFolder "exec-out"
    $propsDir = Join-Path $apiFolder "props"
    $settingsDir = Join-Path $apiFolder "settings"

    foreach ($dir in @($shellDir, $execOutDir, $propsDir, $settingsDir)) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    # Start Emulator
    Write-Log "Launching emulator for AVD '$avdName'..." "VERBOSE"
    $emuProcess = Start-Process -FilePath "emulator" -ArgumentList "-avd", "$avdName", "-no-audio", "-no-window", "-no-boot-anim" -WindowStyle Hidden -PassThru

    Write-Log "Waiting for adb device connection (timeout 240s)..." "VERBOSE"
    $serial = $null
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $serial -and $sw.ElapsedMilliseconds -lt 240000) {
        $devs = Invoke-Adb -Arguments @("devices")
        foreach ($line in $devs) {
            if ($line -match '^(emulator-\d+)\s+device') {
                $candidate = $matches[1]
                $state = (Invoke-Adb -Arguments @("-s", $candidate, "get-state")) -join ""
                if ($state.Trim() -eq "device") {
                    $serial = $candidate
                    break
                }
            }
        }
        if (-not $serial) { Start-Sleep -Seconds 3 }
    }
    $sw.Stop()

    if (-not $serial) {
        Write-Log "Could not determine serial for emulator $avdName (timeout). Skipping..." "ERROR"
        try { Stop-Process -Id $emuProcess.Id -Force -ErrorAction SilentlyContinue } catch {}
        continue
    }

    Write-Log "Target emulator serial: $serial" "SUCCESS"

    Write-Log "Waiting for system boot completion on $serial..." "VERBOSE"
    $bootCompleted = $false
    $timeout = 300
    $elapsed = 0
    while (-not $bootCompleted -and $elapsed -lt $timeout) {
        try {
            $state = (Invoke-Adb -Arguments @("-s", $serial, "get-state")) -join ""
            if ($state.Trim() -eq "device") {
                $bootProp = (Invoke-Adb -Arguments @("-s", $serial, "shell", "getprop", "sys.boot_completed")) -join ""
                if ($bootProp.Trim() -eq "1") {
                    $bootCompleted = $true
                    break
                }
            }
        } catch {}
        Start-Sleep -Seconds 5
        $elapsed += 5
    }

    if (-not $bootCompleted) {
        Write-Log "Timeout waiting for AVD '$avdName' ($serial) to boot. Skipping..." "ERROR"
        Stop-Emulator -Serial $serial -EmuProcess $emuProcess
        continue
    }

    Write-Log "AVD '$avdName' ($serial) booted successfully." "SUCCESS"

    # Execute Commands from Config using serial with multi-attempt discovery and JSON self-updating
    foreach ($cmd in $config.commands) {
        $type = $cmd.type
        $name = $cmd.name
        $configuredHelpArg = $cmd.helpArg

        $candidateHelpArgs = @($configuredHelpArg, "", "help", "-h", "--help") | Select-Object -Unique
        $successOutput = $null
        $workingHelpArg = $configuredHelpArg

        foreach ($arg in $candidateHelpArgs) {
            $adbArgs = if ($arg) { @("-s", $serial, $type, $name, $arg) } else { @("-s", $serial, $type, $name) }
            $commandLine = if ($arg) { "$name $arg" } else { "$name" }
            Write-Log "Running adb -s $serial $type $commandLine" "VERBOSE"
            try {
                $output = Invoke-Adb -Arguments $adbArgs
                $outputStr = ($output -join "`n")
                if ($output -and $outputStr -notmatch "Error:|unknown command|bad argument|no such service|No shell command implementation") {
                    $successOutput = $output
                    $workingHelpArg = $arg
                    break
                }
            } catch {}
        }

        if (-not $successOutput) {
            $adbArgs = if ($configuredHelpArg) { @("-s", $serial, $type, $name, $configuredHelpArg) } else { @("-s", $serial, $type, $name) }
            try {
                $successOutput = Invoke-Adb -Arguments $adbArgs
            } catch {}
            $workingHelpArg = $configuredHelpArg
        }

        $targetDir = if ($type -eq "shell") { $shellDir } else { $execOutDir }
        $safeName = $name -replace '[^\w\-]', '_'
        $outFile = Join-Path $targetDir "$safeName.txt"
        $trimmedOutput = Remove-LeadingEmptyLines $successOutput
        if ($trimmedOutput) {
            $trimmedOutput | Out-File -FilePath $outFile -Encoding utf8
        }
        Write-Log "Saved output to $outFile (HelpArg: '$workingHelpArg')" "VERBOSE"

        if ($workingHelpArg -ne $configuredHelpArg) {
            Update-AdbCommandsJson -JsonPath $ConfigPath -CommandType $type -CommandName $name -HelpArg $workingHelpArg
        }
    }

    # Dynamic svc subcommands discovery and help extraction (safely casting items to strings)
    Write-Log "Discovering svc subcommands on $serial..." "VERBOSE"
    try {
        $svcOutput = Invoke-Adb -Arguments @("-s", $serial, "shell", "svc")
        $subcommands = @()
        $capture = $false
        foreach ($item in $svcOutput) {
            $line = "$item"
            if ($line -match "available commands") {
                $capture = $true
                continue
            }
            if ($capture) {
                $trimmed = $line.Trim()
                if ($trimmed -eq "") { continue }
                if ($line -match '^\s+([a-zA-Z0-9\-_]+)') {
                    $subcmd = $matches[1]
                    if ($subcmd -ne "help") {
                        if ($subcommands -notcontains $subcmd) {
                            $subcommands += $subcmd
                        }
                    }
                } else {
                    $capture = $false
                }
            }
        }

        if ($subcommands.Count -gt 0) {
            Write-Log "Found $($subcommands.Count) svc subcommands: $($subcommands -join ', ')" "SUCCESS"
            foreach ($subcmd in $subcommands) {
                Write-Log "Running adb -s $serial shell svc $subcmd" "VERBOSE"
                try {
                    $subOutput = Invoke-Adb -Arguments @("-s", $serial, "shell", "svc", $subcmd)
                    $subOutFile = Join-Path $shellDir "svc $subcmd.txt"
                    $trimmedSubOutput = Remove-LeadingEmptyLines $subOutput
                    if ($trimmedSubOutput) {
                        $trimmedSubOutput | Out-File -FilePath $subOutFile -Encoding utf8
                    }
                    Write-Log "Saved subcommand help to $subOutFile" "VERBOSE"
                } catch {
                    Write-Log "Error executing svc $subcmd" "WARNING"
                }
            }
        } else {
            Write-Log "No svc subcommands discovered." "WARNING"
        }
    } catch {
        Write-Log "Error discovering svc subcommands: $_" "WARNING"
    }

    # Shell Cmd services discovery and help extraction (Available from API 24+) with AdbCmdCommands.json support
    if ($apiLevel -ge 24) {
        Write-Log "Discovering shell cmd services on $serial..." "VERBOSE"
        try {
            $cmdListOutput = Invoke-Adb -Arguments @("-s", $serial, "shell", "cmd", "-l")
            $cmdDir = Join-Path $shellDir "cmd"
            if (-not (Test-Path $cmdDir)) {
                New-Item -ItemType Directory -Path $cmdDir -Force | Out-Null
            }

            $cmdListFile = Join-Path $cmdDir "!shell cmd -l.txt"
            $trimmedCmdList = Remove-LeadingEmptyLines $cmdListOutput
            if ($trimmedCmdList) {
                $trimmedCmdList | Out-File -FilePath $cmdListFile -Encoding utf8
            }
            Write-Log "Saved cmd service list to $cmdListFile" "VERBOSE"

            $cmdConfigPath = if ($PSScriptRoot) { Join-Path $PSScriptRoot "AdbCmdCommands.json" } else { "AdbCmdCommands.json" }
            $cmdConfigPath = [System.IO.Path]::GetFullPath($cmdConfigPath)
            $cmdConfig = if (Test-Path $cmdConfigPath) { Get-Content $cmdConfigPath -Raw | ConvertFrom-Json } else { [PSCustomObject]@{ commands = @() } }

            $services = @()
            $captureServices = $false
            foreach ($item in $cmdListOutput) {
                $line = "$item".Trim()
                if ($line -eq "") { continue }
                if ($line -match "Currently running services") {
                    $captureServices = $true
                    continue
                }
                if ($captureServices -or $line -notmatch "^error") {
                    if ($line -and $line -notmatch '/' -and $line -notmatch '^-' -and $line -ne "Currently running services:") {
                        if ($services -notcontains $line) {
                            $services += $line
                        }
                    }
                }
            }

            if ($services.Count -gt 0) {
                Write-Log "Found $($services.Count) shell cmd services to query: $($services -join ', ')" "SUCCESS"
                foreach ($svc in $services) {
                    Write-Log "Extracting help for cmd service '$svc'..." "VERBOSE"
                    try {
                        $configuredHelpArg = ""
                        foreach ($c in $cmdConfig.commands) {
                            if ($c.name -eq $svc) {
                                $configuredHelpArg = $c.helpArg
                                break
                            }
                        }

                        $candidateHelpArgs = @($configuredHelpArg, "", "help", "-h", "--help") | Select-Object -Unique
                        $successOutput = $null
                        $workingHelpArg = $configuredHelpArg

                        foreach ($arg in $candidateHelpArgs) {
                            $adbArgs = if ($arg) { @("-s", $serial, "shell", "cmd", $svc, $arg) } else { @("-s", $serial, "shell", "cmd", $svc) }
                            $output = Invoke-Adb -Arguments $adbArgs
                            $outputStr = ($output -join "`n")

                            if ($output -and $outputStr -notmatch "Error:|unknown service|no such service|Bad service|No shell command implementation") {
                                $successOutput = $output
                                $workingHelpArg = $arg
                                break
                            }
                        }

                        if (-not $successOutput) {
                            try {
                                $successOutput = Invoke-Adb -Arguments @("-s", $serial, "shell", "cmd", $svc)
                            } catch {}
                            $workingHelpArg = ""
                        }

                        $safeSvcName = $svc -replace '[^\w\-]', '_'
                        $svcOutFile = Join-Path $cmdDir "$safeSvcName.txt"
                        $trimmedSvcOutput = Remove-LeadingEmptyLines $successOutput
                        if ($trimmedSvcOutput) {
                            $trimmedSvcOutput | Out-File -FilePath $svcOutFile -Encoding utf8
                        }
                        Write-Log "Saved cmd service help for '$svc' to $svcOutFile (HelpArg: '$workingHelpArg')" "VERBOSE"

                        if ($workingHelpArg -ne $configuredHelpArg) {
                            Update-AdbCommandsJson -JsonPath $cmdConfigPath -CommandType "cmd" -CommandName $svc -HelpArg $workingHelpArg
                        }
                    } catch {
                        Write-Log "Error executing cmd $svc" "WARNING"
                    }
                }
            } else {
                Write-Log "No valid shell cmd services discovered." "WARNING"
            }
        } catch {
            Write-Log "Error discovering shell cmd services: $_" "WARNING"
        }
    } else {
        Write-Log "Skipping shell cmd discovery (available from API 24+, current API is $apiLevel)" "VERBOSE"
    }

    # Capture Properties using serial
    Write-Log "Capturing device properties (getprop) on $serial..." "VERBOSE"
    try {
        $props = Invoke-Adb -Arguments @("-s", $serial, "shell", "getprop")
        $trimmedProps = Remove-LeadingEmptyLines $props
        if ($trimmedProps) {
            $trimmedProps | Out-File -FilePath (Join-Path $propsDir "getprop.txt") -Encoding utf8
        }
    } catch {
        Write-Log "Error capturing properties" "WARNING"
    }

    # Capture Settings (system, global, secure) - available from API 23+
    if ($apiLevel -ge 23) {
        foreach ($settingScope in @("system", "global", "secure")) {
            Write-Log "Settings list $settingScope on $serial..." "VERBOSE"
            try {
                $settingsOutput = Invoke-Adb -Arguments @("-s", $serial, "shell", "settings", "list", $settingScope)
                $trimmedSettings = Remove-LeadingEmptyLines $settingsOutput
                if ($trimmedSettings) {
                    $trimmedSettings | Out-File -FilePath (Join-Path $settingsDir "settings_$settingScope.txt") -Encoding utf8
                }
            } catch {
                Write-Log "Error capturing settings" "WARNING"
            }
        }
    } else {
        Write-Log "Skipping settings capture (settings command is available from API 23+, current API is $apiLevel)" "VERBOSE"
    }

    # Shutdown Emulator using serial
    Write-Log "Shutting down emulator $serial ($avdName)..." "VERBOSE"
    Stop-Emulator -Serial $serial -EmuProcess $emuProcess
    Write-Log "AVD '$avdName' ($serial) processed and closed." "SUCCESS"
}

Write-Log "All target AVDs processed successfully. Raw data saved to: $OutputFolder" "SUCCESS"
