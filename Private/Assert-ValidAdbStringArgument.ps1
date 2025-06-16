# This is for validating ADB string arguments, that can't be sanitized by ConvertTo-ValidAdbStringArgument

function Assert-ValidAdbStringArgument {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $InputObject,

        [Parameter(Mandatory)]
        [string] $ArgumentName
    )

    if ($InputObject.Contains('"')) {
        Write-Error "The argument '$ArgumentName' cannot contain double quotes. Input: '$InputObject'" -ErrorAction Stop
    }
}
