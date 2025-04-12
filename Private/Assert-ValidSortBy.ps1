function Assert-ValidSortBy {

    param (
        [PSCustomObject] $InputObject
    )

    if ($InputObject.PSObject.Properties.Name -notcontains 'ColumnName') {
        Write-Error "SortBy must specify a column name. Input: $InputObject" -ErrorAction Stop
    }
    if ($InputObject.ColumnName.Contains(' ')) {
        Write-Error "SortBy column name can't contain spaces. Input: $InputObject" -ErrorAction Stop
    }
    if ($InputObject.PSObject.Properties.Name -notcontains 'Type') {
        Write-Error "SortBy must specify a column name. Input: $InputObject" -ErrorAction Stop
    }
    if ($InputObject.Type -ne 'Ascending' -and $InputObject.Type -ne 'Descending') {
        Write-Error "SortBy Type must be one of ['Ascending', 'Descending']. Input: $InputObject" -ErrorAction Stop
    }
    if ($InputObject.PSObject.Methods.Name -notcontains 'ToAdbArgument') {
        Write-Error "SortBy Type must have a ToAdbArgument method. Input: $InputObject" -ErrorAction Stop
    }
}
