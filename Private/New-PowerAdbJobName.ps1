function New-PowerAdbJobName {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Tag
    )

    return "PowerAdb:$Tag`:$PowerAdbJobNameSuffix"
}
