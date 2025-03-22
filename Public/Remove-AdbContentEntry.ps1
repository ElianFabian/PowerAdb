function Remove-AdbContentEntry {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Parameter(Mandatory)]
        [string] $Where
    )

    begin {
        $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell content delete --uri '$Uri' $bindingArgs$whereArg" -Verbose:$VerbosePreference
        }
    }
}



# TODO: Add --user, and --extra options (according to the documentation --bind is supported, but it does not work)
# usage: adb shell content delete --uri <URI> [--user <USER_ID>] --bind <BINDING> [--bind <BINDING>...] [--where <WHERE>] [--extra <BINDING>...]
#   Example:
#   # Remove "new_setting" secure setting.
#   adb shell content delete --uri content://settings/secure --where "name='new_setting'"
