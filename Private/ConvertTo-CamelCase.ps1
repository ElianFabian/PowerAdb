function ConvertTo-CamelCase {

    param (
        [string] $InputObject
    )

    $words = $InputObject -split '\s+'

    if ($words.Count -gt 0) {
        $camelCase = [System.Text.StringBuilder]::new($words[0].ToLowerInvariant())

        foreach ($word in $words[1..($words.Count - 1)]) {
            $camelCase.Append($word.Substring(0, 1).ToUpperInvariant() + $word.Substring(1).ToLowerInvariant()) > $null
        }
        return $camelCase.ToString()
    }

    return $InputObject.ToLowerInvariant()
}
