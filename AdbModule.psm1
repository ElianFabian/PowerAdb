#Requires -Version 5.1

$PublicFunction = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -File -ErrorAction SilentlyContinue)

$incorrectFiles = $PublicFunction | Where-Object {
    .\Test-IncorrectFileFunction.ps1 -Path $_.FullName
}

if ($incorrectFiles) {
    $formattedOutput = $incorrectFiles -join "`n"
    Write-Error "There are functions whose name doesn't match its filename: `n$formattedOutput"
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
