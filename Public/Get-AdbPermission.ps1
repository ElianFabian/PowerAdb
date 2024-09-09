function Get-AdbPermission {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([string[]], [PSCustomObject[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(ParameterSetName = "ByGroup")]
        [switch] $ByGroup,

        [switch] $DangerousOnly,

        [switch] $VisibleToUser
    )

    process {
        if ($DangerousOnly) {
            $dangerousOnlyParam = "-d"
        }
        if ($VisibleToUser) {
            $visibleToUserParam = '-u'
        }

        if ($ByGroup) {
            foreach ($id in $DeviceId) {
                $permissionsByGroup = @{}
                $currentGroup = $null

                Invoke-AdbExpression -DeviceId $id -Command "shell pm list permissions -g $dangerousOnlyParam $visibleToUserParam" `
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
        }
        else {
            $DeviceId | Invoke-AdbExpression -Command "shell pm list permissions $dangerousOnlyParam $visibleToUserParam" `
            | Where-Object { $_ } `
            | Select-Object -Skip 1 `
            | ForEach-Object { $_.Replace("permission:", "") }
        }
    }
}
