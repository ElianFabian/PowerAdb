#Requires -Version 5.1

try {
    Add-Type -TypeDefinition (Get-Content -LiteralPath "$PSScriptRoot/Public/Class/Exceptions.cs" -Raw) -Language CSharp -ErrorAction Ignore
}
catch {
    # no-op, we just ignore the errors in case the classes are already loaded
}

$PublicFunction = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -File -ErrorAction Ignore)
$PrivateFunction = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -File -ErrorAction Ignore)

$incorrectFiles = $PublicFunction | Where-Object {
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

$rightFiles = $PublicFunction | Where-Object {
    $_.FullName -notin $incorrectFiles
}

. "$PSScriptRoot/ArgumentCompleter.ps1" -PublicFunctionFileName $rightFiles

if (-not (Get-Command -Name Start-ThreadJob -ErrorAction Ignore)) {
    $startThreadJobContent = Get-Content -LiteralPath "$PSScriptRoot/External/ThreadJob/Microsoft.PowerShell.ThreadJob.cs" -Raw
    Add-Type -TypeDefinition $startThreadJobContent -Language CSharp
}



$DisableCache = 'PowerAdb.DisableCache' -in $args

if (-not $DisableCache) {
    # Used to store immutable values
    New-Variable -Name PowerAdbCache -Value @{} -Scope Script -Force -Option ReadOnly
}

# Used to create jobs with unique names that we can remove when needed
New-Variable -Name PowerAdbJobNameSuffix -Value "$(New-Guid)" -Scope Script -Force -Option ReadOnly

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Remove-Variable -Name PowerAdbCache -Scope Script -Force -ErrorAction Ignore
    Get-Job | Where-Object { $_.Name.EndsWith($PowerAdbJobNameSuffix) } | Stop-Job -PassThru | Remove-Job -Force
}

Export-ModuleMember -Function $PublicFunction.BaseName
