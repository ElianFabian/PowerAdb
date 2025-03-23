function Get-AdbContentEntryType {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri
    )

    process {
        foreach ($id in $DeviceId) {
            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell content gettype --uri '$Uri'" -Verbose:$VerbosePreference

            $rawResult.Substring('Result: '.Length)
        }
    }
}



# TODO: Add --user option
# usage: adb shell content gettype --uri <URI> [--user <USER_ID>]
#   Example:
#   adb shell content gettype --uri content://media/internal/audio/media/
