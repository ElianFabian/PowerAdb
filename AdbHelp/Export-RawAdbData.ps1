param(
    [Parameter(Mandatory = $false)]
    [double]$MinApi = 16,

    [Parameter(Mandatory = $false)]
    [double]$MaxApi = 37.1,

    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = "$PSScriptRoot/.raw-adb-help",

    [Parameter(Mandatory = $false)]
    [string]$OllamaModel = "qwen2.5:14b",

    [Parameter(Mandatory = $false)]
    [string]$OllamaUri = "http://localhost:11434/api/generate",

    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot/AdbCommands.json"
)

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

# Resolve ConfigPath
if (-not $ConfigPath -or -not (Test-Path $ConfigPath)) {
    if ($PSScriptRoot) {
        $ConfigPath = Join-Path $PSScriptRoot "AdbCommands.json"
    }
    if (-not (Test-Path $ConfigPath)) {
        $ConfigPath = "AdbCommands.json"
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
$avdListOutput = & emulator -list-avds 2>&1
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

    Write-Log "==================================================" "INFO"
    Write-Log "Processing AVD: $avdName (API Level: $apiLevel)" "INFO"
    Write-Log "==================================================" "INFO"

    # Ensure any previous/lingering emulators are shut down before starting a new one
    $activeEmus = @(& adb devices) | Where-Object { $_ -match 'emulator-\d+' }
    foreach ($line in $activeEmus) {
        if ($line -match '^(emulator-\d+)') {
            $existingSerial = $matches[1]
            Write-Log "Shutting down lingering emulator $existingSerial..." "VERBOSE"
            try { & adb -s $existingSerial emu kill } catch {}
        }
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
    $emuProcess = Start-Process -FilePath "emulator" -ArgumentList "-avd", "$avdName", "-no-audio", "-no-window" -PassThru

    Write-Log "Waiting for adb device connection (timeout 120s)..." "VERBOSE"
    $serial = $null
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $serial -and $sw.ElapsedMilliseconds -lt 120000) {
        $devs = & adb devices 2>&1
        foreach ($line in $devs) {
            if ($line -match '^(emulator-\d+)\s+device') {
                $candidate = $matches[1]
                $state = & adb -s $candidate get-state 2>&1
                if ($state -eq "device") {
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
            $state = (& adb -s $serial get-state 2>&1).Trim()
            if ($state -eq "device") {
                $bootProp = (& adb -s $serial shell getprop sys.boot_completed 2>&1).Trim()
                if ($bootProp -eq "1") {
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
        try { & adb -s $serial emu kill } catch {}
        try { Stop-Process -Id $emuProcess.Id -Force -ErrorAction SilentlyContinue } catch {}
        continue
    }

    Write-Log "AVD '$avdName' ($serial) booted successfully." "SUCCESS"

    # Execute Commands from Config using serial
    foreach ($cmd in $config.commands) {
        $type = $cmd.type
        $name = $cmd.name
        $helpArg = $cmd.helpArg

        $commandLine = if ($helpArg) { "$name $helpArg" } else { "$name" }
        Write-Log "Running adb -s $serial $type $commandLine" "VERBOSE"

        try {
            $output = & adb -s $serial $type $commandLine 2>&1
            $targetDir = if ($type -eq "shell") { $shellDir } else { $execOutDir }
            $safeName = $name -replace '[^\w\-]', '_'
            $outFile = Join-Path $targetDir "$safeName.txt"
            $output | Out-File -FilePath $outFile -Encoding utf8
            Write-Log "Saved output to $outFile" "VERBOSE"
        } catch {
            Write-Log "Error executing command" "WARNING"
        }
    }

    # Dynamic svc subcommands discovery and help extraction (safely casting items to strings)
    Write-Log "Discovering svc subcommands on $serial..." "VERBOSE"
    try {
        $svcOutput = & adb -s $serial shell svc 2>&1
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
                    $subOutput = & adb -s $serial shell svc $subcmd 2>&1
                    $subOutFile = Join-Path $shellDir "svc $subcmd.txt"
                    $subOutput | Out-File -FilePath $subOutFile -Encoding utf8
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

    # Capture Properties using serial
    Write-Log "Capturing device properties (getprop) on $serial..." "VERBOSE"
    try {
        $props = & adb -s $serial shell getprop 2>&1
        $props | Out-File -FilePath (Join-Path $propsDir "getprop.txt") -Encoding utf8
    } catch {
        Write-Log "Error capturing properties" "WARNING"
    }

    # Capture Settings (system, global, secure) - available from API 23+
    if ($apiLevel -ge 23) {
        foreach ($settingScope in @("system", "global", "secure")) {
            Write-Log "Capturing settings list $settingScope on $serial..." "VERBOSE"
            try {
                $settingsOutput = & adb -s $serial shell settings list $settingScope 2>&1
                $settingsOutput | Out-File -FilePath (Join-Path $settingsDir "settings_$settingScope.txt") -Encoding utf8
            } catch {
                Write-Log "Error capturing settings" "WARNING"
            }
        }
    } else {
        Write-Log "Skipping settings capture (settings command is available from API 23+, current API is $apiLevel)" "VERBOSE"
    }

    # Shutdown Emulator using serial
    Write-Log "Shutting down emulator $serial ($avdName)..." "VERBOSE"
    try {
        & adb -s $serial emu kill
        Start-Sleep -Seconds 3
    } catch {}

    if (-not $emuProcess.HasExited) {
        Stop-Process -Id $emuProcess.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Log "AVD '$avdName' ($serial) processed and closed." "SUCCESS"
}

Write-Log "All target AVDs processed successfully. Raw data saved to: $OutputFolder" "SUCCESS"
