<#
.SYNOPSIS
    Imports raw adb help output into the PowerAdb AdbHelp directory structure.

.DESCRIPTION
    This helper keeps the AdbHelp folder conventions consistent with the existing repo:
    - one directory per command family, such as shell cmd, settings, or wm
    - one file per command version or device-specific snapshot

    It accepts either a file path or raw text and writes the output under the repo's
    AdbHelp folder while preserving the naming style already used in this project.

.EXAMPLE
    .\AdbHelp\Import-AdbHelp.ps1 -InputPath .\new-help.txt -RelativeFolder 'shell cmd' -FileName 'bluetooth_manager 35'

.EXAMPLE
    .\AdbHelp\Import-AdbHelp.ps1 -InputText $text -RelativeFolder 'shell cmd' -FileName 'shell cmd -l 36.1' -FileNamePrefix '!'

.EXAMPLE
    .\AdbHelp\Import-AdbHelp.ps1 -Command 'shell cmd -l' -VersionLabel '36.1' -FileNamePrefix '!' -RelativeFolder 'shell cmd' -RawOutput $adbText
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$Root = $PSScriptRoot,

    [Parameter()]
    [string]$InputPath,

    [Parameter()]
    [string]$InputText,

    [Parameter()]
    [string]$RelativeFolder,

    [Parameter()]
    [string]$FileName,

    [Parameter()]
    [string]$FileNamePrefix = '',

    [Parameter()]
    [string]$Command,

    [Parameter()]
    [string]$VersionLabel,

    [Parameter()]
    [string]$RawOutput,

    [Parameter()]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Normalize-AdbHelpName {
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    $normalized = $Value.Trim()
    $normalized = $normalized -replace '[\\/:*?"<>|]', '-' 
    $normalized = $normalized -replace '\s+', ' ' 
    return $normalized.Trim()
}

function Resolve-AdbHelpDestination {
    param(
        [Parameter(Mandatory)]
        [string]$RootDir,

        [Parameter()]
        [string]$Folder,

        [Parameter()]
        [string]$File,

        [Parameter()]
        [string]$Prefix,

        [Parameter()]
        [string]$CommandName,

        [Parameter()]
        [string]$Version
    )

    if (-not $Folder) {
        if ($CommandName) {
            $parts = @($CommandName -split '\s+') | Where-Object { $_ }
            if ($parts.Count -ge 2) {
                $Folder = "$($parts[0]) $($parts[1])"
            }
            elseif ($parts.Count -eq 1) {
                $Folder = $parts[0]
            }
        }
    }

    if (-not $Folder) {
        throw 'A folder name is required. Use -RelativeFolder or provide a command like "shell cmd -l".'
    }

    if (-not $File) {
        if ($CommandName -and $Version) {
            $File = "$CommandName $Version"
        }
        else {
            throw 'A file name is required. Use -FileName or provide both -Command and -VersionLabel.'
        }
    }

    $fileName = Normalize-AdbHelpName -Value "$Prefix$File"
    if (-not $fileName.EndsWith('.txt', [System.StringComparison]::OrdinalIgnoreCase)) {
        $fileName = "$fileName.txt"
    }

    return [PSCustomObject]@{
        Directory = (Join-Path $RootDir $Folder)
        FileName  = $fileName
    }
}

if (-not $InputPath -and -not $InputText -and -not $RawOutput) {
    throw 'Provide either -InputPath, -InputText, or -RawOutput.'
}

if ($InputPath -and -not (Test-Path -LiteralPath $InputPath)) {
    throw "Input path '$InputPath' does not exist."
}

if ($RawOutput -and -not $Command -and -not $VersionLabel) {
    throw 'When using -RawOutput, provide -Command and -VersionLabel or -FileName.'
}

if ($Command -and -not $VersionLabel -and -not $FileName) {
    throw 'When using -Command, provide -VersionLabel or a direct -FileName.'
}

if ($InputText) {
    $content = $InputText
}
elseif ($InputPath) {
    $content = Get-Content -LiteralPath $InputPath -Raw
}
elseif ($RawOutput) {
    $content = $RawOutput
}
else {
    throw 'Unable to determine the source text to import.'
}

if (-not $FileName -and $Command -and $VersionLabel) {
    $FileName = "$Command $VersionLabel"
}

$destination = Resolve-AdbHelpDestination -RootDir $Root -Folder $RelativeFolder -File $FileName -Prefix $FileNamePrefix -CommandName $Command -Version $VersionLabel

if (-not (Test-Path -LiteralPath $destination.Directory)) {
    New-Item -Path $destination.Directory -ItemType Directory -Force | Out-Null
}

$fullPath = Join-Path $destination.Directory $destination.FileName

if ((Test-Path -LiteralPath $fullPath) -and -not $Force) {
    throw "Destination file already exists: $fullPath. Use -Force to overwrite it."
}

if ($PSCmdlet.ShouldProcess($fullPath, 'Write adb help snapshot')) {
    Set-Content -LiteralPath $fullPath -Value $content -Encoding UTF8
    Write-Host "Imported adb help snapshot to: $fullPath"
    return $fullPath
}
