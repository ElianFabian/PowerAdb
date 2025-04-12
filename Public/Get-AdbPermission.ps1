function Get-AdbPermission {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([string[]], [PSCustomObject])]
    param (
        [string] $DeviceId,

        [Parameter(ParameterSetName = "ByGroup")]
        [switch] $ByGroup,

        [switch] $DangerousOnly,

        [switch] $VisibleToUser
    )

    if ($DangerousOnly) {
        $dangerousOnlyParam = " -d"
    }
    if ($VisibleToUser) {
        $visibleToUserParam = ' -u'
    }

    if ($ByGroup) {
        $permissionsByGroup = @{}
        $currentGroup = $null

        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm list permissions -g$dangerousOnlyParam$visibleToUserParam" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
        | Select-Object -Skip 1 `
        | Where-Object { $_ } `
        | ForEach-Object {
            $isGroup = -not $_.Contains('  ')
            if ($isGroup) {
                $groupName = $_.Replace('group:', '').Replace(':', '')
                $currentGroup = $groupName
                $permissionsByGroup.$groupName = [System.Collections.Generic.List[string]]::new()
            }
            else {
                $permissionName = $_.Replace('  permission:', '')
                $permissionsByGroup.$currentGroup.Add($permissionName)
            }
        }

        [PSCustomObject] $permissionsByGroup
    }
    else {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm list permissions $dangerousOnlyParam $visibleToUserParam" -Verbose:$VerbosePreference `
        | Where-Object { $_ } `
        | Select-Object -Skip 1 `
        | ForEach-Object { $_.Replace("permission:", "") }
    }
}
