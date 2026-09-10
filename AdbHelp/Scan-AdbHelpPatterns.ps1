<#
.SYNOPSIS
    Detects whether adb help snapshots are range extensions or new version snapshots based on file naming patterns only.

.DESCRIPTION
    This script intentionally ignores help content and looks only at file naming conventions already used in AdbHelp.

    The goal is to decide whether a captured help file should be treated as:
      - a range extension (same command, same doc family, version expanded), or
      - a new version snapshot (significant change, create a new file for that Android/adb version)

    It is designed for the repo's established naming patterns such as:
      - bluetooth_manager 35.txt
      - bluetooth_manager 35-36.txt
      - !shell cmd -l 36.1.txt
      - !shell cmd 30-37.txt

    For shell cmd, the script can also accept a list of services from `adb shell cmd -l` and check whether each service has a matching doc pattern.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Root = $PSScriptRoot,

    [Parameter()]
    [string[]]$CommandList,

    [Parameter()]
    [string[]]$ShellCmdServices,

    [Parameter()]
    [switch]$IncludeUntracked
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ComparableVersion {
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    $clean = $Value.Trim()
    if (-not $clean) { return $null }

    $clean = $clean -replace '\s+', ''
    $clean = $clean -replace '\(.*\)$', ''

    if ($clean -match '^(\d+)(?:\.(\d+))?$') {
        return [int[]]@([int]$Matches[1], [int]($Matches[2] ?? 0))
    }

    if ($clean -match '^(\d+)(?:\.(\d+))?\s*-\s*(\d+)(?:\.(\d+))?$') {
        $min = [int]$Matches[1]
        $minMinor = [int]($Matches[2] ?? 0)
        $max = [int]$Matches[3]
        $maxMinor = [int]($Matches[4] ?? 0)
        return [int[]]@($min, $minMinor, $max, $maxMinor)
    }

    return $null
}

function Get-CommandBaseName {
    param(
        [Parameter(Mandatory)]
        [string]$FileName
    )

    $base = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $base = $base.Trim()
    $base = $base.Replace('!', '')
    $base = $base.Trim()

    $versionMatch = [regex]::Match($base, '.*?(?<Prefix>.+?)\s+(?<Version>\d+(?:\.\d+)?(?:\s*-\s*\d+(?:\.\d+)?)?)(?:\s*\(.*\))?$')
    if ($versionMatch.Success) {
        return $versionMatch.Groups['Prefix'].Value.Trim()
    }

    return $base.Trim()
}

function Get-CommandVersion {
    param(
        [Parameter(Mandatory)]
        [string]$FileName
    )

    $base = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $base = $base.Trim()
    $base = $base.TrimStart('!')

    $versionMatch = [regex]::Match($base, '.*?(?<Prefix>.+?)\s+(?<Version>\d+(?:\.\d+)?(?:\s*-\s*\d+(?:\.\d+)?)?)(?:\s*\(.*\))?$')
    if ($versionMatch.Success) {
        return $versionMatch.Groups['Version'].Value.Trim()
    }

    return $null
}

function Get-PatternSummary {
    param(
        [Parameter(Mandatory)]
        [string[]]$Files
    )

    $result = foreach ($file in $Files) {
        $name = Get-CommandBaseName -FileName $file
        $version = Get-CommandVersion -FileName $file
        [PSCustomObject]@{
            FileName = $file
            BaseName = $name
            Version  = $version
            IsVersioned = -not [string]::IsNullOrWhiteSpace($version)
        }
    }

    return $result
}

function Get-NearestVersionRange {
    param(
        [Parameter(Mandatory)]
        [string[]]$Versions
    )

    $numbers = @()
    foreach ($v in $Versions) {
        $parsed = Get-ComparableVersion -Value $v
        if ($parsed) { $numbers += $parsed }
    }

    if (-not $numbers) { return $null }

    $max = $numbers | Sort-Object { $_[0], $_[1] } | Select-Object -Last 1
    return $max
}

function Get-RelativeRoot {
    param(
        [Parameter(Mandatory)]
        [string]$RootPath
    )

    $full = (Resolve-Path -LiteralPath $RootPath).Path
    return $full
}

function Get-MissingShellCmdServices {
    param(
        [Parameter(Mandatory)]
        [string[]]$KnownServices,
        [Parameter(Mandatory)]
        [string[]]$CurrentDocs
    )

    $known = $KnownServices | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $docs = $CurrentDocs | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    $missing = @()
    foreach ($service in $known) {
        $match = $docs | Where-Object {
            $_ -eq $service -or $_ -match "^$([regex]::Escape($service))\s+\d"
        }

        if (-not $match) {
            $missing += $service
        }
    }

    return $missing
}

$rootPath = Get-RelativeRoot -RootPath $Root
$allFiles = Get-ChildItem -Path $rootPath -Recurse -File -ErrorAction Ignore | ForEach-Object { $_.FullName }

$grouped = @{}
foreach ($file in $allFiles) {
    $relative = [System.IO.Path]::GetRelativePath($rootPath, $file)
    $base = Get-CommandBaseName -FileName $relative
    $version = Get-CommandVersion -FileName $relative

    if (-not $grouped.ContainsKey($base)) {
        $grouped[$base] = @()
    }

    $grouped[$base] += [PSCustomObject]@{
        RelativePath = $relative
        Version      = $version
        FileName     = [System.IO.Path]::GetFileName($file)
    }
}

$scanned = foreach ($key in $grouped.Keys | Sort-Object) {
    $entries = $grouped[$key] | Sort-Object { $_.Version }
    $versions = @($entries | Where-Object { $_.Version } | ForEach-Object { $_.Version })

    $last = $versions | Select-Object -Last 1
    $state = 'No version metadata'
    if ($versions.Count -gt 0) {
        $state = 'Versioned snapshot'
        if ($versions.Count -gt 1) {
            $state = 'Range or multi-version snapshot'
        }
    }

    [PSCustomObject]@{
        BaseName = $key
        Files    = $entries
        VersionList = $versions
        LatestVersion = $last
        State = $state
    }
}

if (-not $CommandList) {
    $CommandList = $scanned | ForEach-Object { $_.BaseName }
}

$signals = foreach ($command in $CommandList | Sort-Object -Unique) {
    $docFiles = $grouped[$command]
    if (-not $docFiles) {
        $candidate = [PSCustomObject]@{
            Command = $command
            Action  = 'Missing doc snapshot'
            Reason  = 'No matching file-name pattern found for this command in AdbHelp.'
        }
        if ($IncludeUntracked) {
            $candidate
        }
        continue
    }

    $versions = @($docFiles | Where-Object { $_.Version } | ForEach-Object { $_.Version } | Sort-Object)
    $latest = $versions | Select-Object -Last 1

    if (-not $latest) {
        [PSCustomObject]@{
            Command = $command
            Action  = 'Needs naming review'
            Reason  = 'Found doc files but no recognizable version metadata in their names.'
            Files   = $docFiles.RelativePath
        }
        continue
    }

    $latestParsed = Get-ComparableVersion -Value $latest
    $rangeExtension = $false
    if ($latest -match '-\s*\d') {
        $rangeExtension = $true
    }

    [PSCustomObject]@{
        Command = $command
        Action  = if ($rangeExtension) { 'Extend existing range' } else { 'Keep current version snapshot' }
        Reason  = if ($rangeExtension) { 'The latest file name already shows a range, so the doc family is likely still the same.' } else { 'The current naming pattern suggests the command doc is still the same family and has not yet been split into a new documented version.' }
        LatestVersion = $latest
        Files = @($docFiles.RelativePath)
    }
}

if ($ShellCmdServices) {
    $serviceTargets = foreach ($service in $ShellCmdServices | Sort-Object -Unique) {
        $base = $service.Trim()
        if (-not $base) { continue }

        $matching = $grouped.Keys | Where-Object {
            $_ -match "(^|\s)$([regex]::Escape($base))($|\s)" -or $_ -eq $base
        }

        if ($matching) {
            [PSCustomObject]@{
                Service = $base
                Action  = 'Doc exists'
                MatchingNames = @($matching)
            }
        }
        else {
            [PSCustomObject]@{
                Service = $base
                Action  = 'Missing doc snapshot'
                MatchingNames = @()
            }
        }
    }
}

return [PSCustomObject]@{
    Root = $rootPath
    TotalGroups = @($scanned).Count
    CommandSummary = @($signals)
    ShellCmdServices = if ($ShellCmdServices) { @($serviceTargets) } else { @() }
}
