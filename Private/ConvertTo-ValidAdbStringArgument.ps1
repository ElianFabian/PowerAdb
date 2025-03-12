function ConvertTo-ValidAdbStringArgument {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $InputObject
    )


    return $InputObject.Replace("\", "\\").Replace('"', '\"').Replace("'", "''")
}
