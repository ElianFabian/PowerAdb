function Assert-ValidContentEntryValue {

    param (
        [PSCustomObject] $InputObject
    )

    foreach ($propertyName in $InputObject.PSObject.Properties.Name) {
        if ($propertyName.Contains(' ')) {
            Write-Error "Properties can't contain spaces. Property: '$_', Input: $InputObject" -ErrorAction Stop
        }
    }
}
