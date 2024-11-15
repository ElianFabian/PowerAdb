#Requires -Version 5.1

$PublicFunction = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -File -ErrorAction SilentlyContinue)
$PrivateFunction = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -File -ErrorAction SilentlyContinue)

$incorrectFiles = $PublicFunction | Where-Object {
    #FIXME: This script is called in AdbArgumentCompleter.ps1 and in here
    # that makes importing the script slow, we'll try to fix it
    & "$PSScriptRoot/Test-IncorrectFileFunction.ps1" -Path $_.FullName
}

if ($incorrectFiles) {
    $formattedOutput = $incorrectFiles -join "`n"
    Write-Error "There are functions whose name doesn't match its filename: `n$formattedOutput"
}


foreach ($import in @($PublicFunction + $PrivateFunction)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import preloaded script '$($import.FullName)': $_"
    }
}


. "$PSScriptRoot/AdbArgumentCompleter.ps1"


if (-not (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue)) {
    $startThreadJobContent = Get-Content -LiteralPath "$PSScriptRoot/External/ThreadJob/Microsoft.PowerShell.ThreadJob.cs" -Raw
    Add-Type -TypeDefinition $startThreadJobContent -Language CSharp
}


# Used to store immutable values
New-Variable -Name AdbCache -Value @{} -Scope Script -Force -Option ReadOnly

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Remove-Variable -Name AdbCache -Scope Script -Force
    Get-Job | Where-Object { $_.Name.StartsWith("PowerAdb.RemoveCacheFor:") } | Stop-Job -PassThru | Remove-Job -Force
}

Export-ModuleMember -Function $PublicFunction.BaseName
