function Set-AdbContentEntry {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Parameter(Mandatory)]
        [string] $Where,

        [Alias('Bindings')]
        [Parameter(Mandatory)]
        [object] $Values
    )

    begin {
        $valueAsPsCustomObject = [PSCustomObject] $Values

        $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"

        $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell content update --uri '$Uri'$bindingArgs$whereArg" -Verbose:$VerbosePreference
        }
    }
}



# TODO: Add --user, and --extra options
# usage: adb shell content update --uri <URI> [--user <USER_ID>] [--where <WHERE>] [--extra <BINDING>...]
#   <WHERE> is a SQL style where clause in quotes (You have to escape single quotes - see example below).
#   Example:
#   # Change "new_setting" secure setting to "newer_value".
#   adb shell content update --uri content://settings/secure --bind value:s:newer_value --where "name='new_setting'"
