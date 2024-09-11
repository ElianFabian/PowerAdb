#Requires -Version 5.1

$PublicFunction = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -File -ErrorAction SilentlyContinue)

$incorrectFiles = $PublicFunction | Where-Object {
    $fileContent = Get-Content -Path $_.FullName -Raw
    $fileBaseName = $_.BaseName

    if ( [string]::IsNullOrWhiteSpace($fileContent)) {
        return $true
    }
    if ($fileContent -notmatch "function $fileBaseName\s*{") {
        return $true
    }

    return $false
}

if ($incorrectFiles) {
    $formattedOutput = $incorrectFiles -join "`n"
    Write-Error "There are functions whose name doesn't match its filename: `n$formattedOutput"
    exit
}


foreach ($import in @($PublicFunction)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import preloaded script '$($import.FullName)': $_"
    }
}


. "$PSScriptRoot/AdbArgumentCompleter.ps1"

Export-ModuleMember -Function $PublicFunction.BaseName
