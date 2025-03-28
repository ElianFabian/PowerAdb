function Remove-AdbContentEntry {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [Parameter(Mandatory)]
        [string] $Where
    )

    begin {
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
        $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell content delete --uri '$Uri' $userArg$whereArg" -Verbose:$VerbosePreference
        }
    }
}



# usage: adb shell content delete --uri <URI> [--user <USER_ID>] --bind <BINDING> [--bind <BINDING>...] [--where <WHERE>] [--extra <BINDING>...]
#   Example:
#   # Remove "new_setting" secure setting.
#   adb shell content delete --uri content://settings/secure --where "name='new_setting'"
