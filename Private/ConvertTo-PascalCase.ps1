function ConvertTo-PascalCase {

    param (
        [string] $InputObject
    )

    if ($InputObject -match ' ') {
        $words = $InputObject -split ' '
        $pascalCase = [System.Text.StringBuilder]::new()
        foreach ($word in $words) {
            $pascalCase.Append($word.Substring(0, 1).ToUpperInvariant()) > $null
            $pascalCase.Append($word.Substring(1).ToLowerInvariant()) > $null
        }
        return $pascalCase.ToString()
    }

    return $InputObject.Substring(0,1).ToUpperInvariant() +  $InputObject.Substring(1).ToLowerInvariant()
}
