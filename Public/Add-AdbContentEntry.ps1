function Add-AdbContentEntry {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Alias('Bindings')]
        [Parameter(Mandatory)]
        [object] $Values
    )

    begin {
        $valueAsPsCustomObject = [PSCustomObject] $Values

        $bindingArgs = $valueAsPsCustomObject.PSObject.Properties `
        | Where-Object { $_.MemberType -eq 'NoteProperty' } `
        | ForEach-Object {
            $type = $_.Value.GetType().Name

            $entryType = if ($null -eq $_.Value) {
                'n'
            }
            else {
                switch ($type) {
                    'Boolean' { 'b' }
                    'String' { 's' }
                    'Int32' { 'i' }
                    'Int64' { 'l' }
                    'Single' { 'f' }
                    'Double' { 'd' }
                    default { 's' }
                }
            }

            $sanitizedValue = $_.Value
            if ($type -eq 'Single' -or $type -eq 'Double') {
                $sanitizedValue = $sanitizedValue.ToString([System.Globalization.CultureInfo]::InvariantCulture)
            }
            elseif ($type -eq 'Boolean') {
                $sanitizedValue = if ($sanitizedValue) { 'true' } else { 'false' }
            }

            $entry = "$($_.Name):$entryType`:$($_.Value)"
            $sanitizedEntry = ConvertTo-ValidAdbStringArgument $entry

            " --bind $sanitizedEntry"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell content insert --uri '$Uri'$bindingArgs" -Verbose:$VerbosePreference
        }
    }
}



# TODO: Add --user, and --extra options
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
