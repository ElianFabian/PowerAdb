function New-AdbSortBy {

    param (
        [string] $ColumnName,

        [ValidateSet('Ascending', 'Descending')]
        [string] $Type = 'Ascending'
    )

    $output = [PSCustomObject]@{
        ColumnName = $ColumnName
        Type       = $Type
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArgument' -Value {
        $sortType = switch ($this.Type) {
            'Ascending' { 'ASC' }
            'Descending' { 'DESC' }
        }
        $arg = ConvertTo-ValidAdbStringArgument "$($this.ColumnName) $sortType"

        return " --sort $arg"
    }

    return $output
}
