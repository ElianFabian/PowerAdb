function ConvertTo-ValidAdbStringArgument {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $InputObject
    )

    return "'" + '"' + $InputObject.Replace("\", "\\").Replace('"', '\"').Replace("'", "''").Replace('`', '\`') + '"' + "'"
}
