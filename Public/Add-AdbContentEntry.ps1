function Add-AdbContentEntry {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [Alias('Bindings')]
        [Parameter(Mandatory)]
        [object] $Values
    )

    begin {
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }

        $valueAsPsCustomObject = [PSCustomObject] $Values
        $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell content insert --uri '$Uri'$userArg$bindingArgs" -Verbose:$VerbosePreference
        }
    }
}



# usage: adb shell content insert --uri <URI> [--user <USER_ID>] --bind <BINDING> [--bind <BINDING>...] [--extra <BINDING>...]
#   <URI> a content provider URI.
#   <BINDING> binds a typed value to a column and is formatted:
#   <COLUMN_NAME>:<TYPE>:<COLUMN_VALUE> where:
#   <TYPE> specifies data type such as:
#   b - boolean, s - string, i - integer, l - long, f - float, d - double, n - null
#   Note: Omit the value for passing an empty string, e.g column:s:
#   Example:
#   # Add "new_setting" secure setting with value "new_value".
#   adb shell content insert --uri content://settings/secure --bind name:s:new_setting --bind value:s:new_value
