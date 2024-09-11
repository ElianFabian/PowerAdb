$Path | Get-ChildItem | Where-Object {
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
