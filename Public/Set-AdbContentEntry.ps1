function Set-AdbContentEntry {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [Parameter(Mandatory)]
        [string] $Where,

        [Alias('Bindings')]
        [Parameter(Mandatory)]
        [object] $Values
    )

    begin {
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
        $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"

        $valueAsPsCustomObject = [PSCustomObject] $Values
        $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell content update --uri '$Uri'$userArg$bindingArgs$whereArg" -Verbose:$VerbosePreference
        }
    }
}



# usage: adb shell content update --uri <URI> [--user <USER_ID>] [--where <WHERE>] [--extra <BINDING>...]
#   <WHERE> is a SQL style where clause in quotes (You have to escape single quotes - see example below).
#   Example:
#   # Change "new_setting" secure setting to "newer_value".
#   adb shell content update --uri content://settings/secure --bind value:s:newer_value --where "name='new_setting'"
