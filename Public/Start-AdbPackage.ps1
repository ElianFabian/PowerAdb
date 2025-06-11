# Starts an application or resumes it if it's already open
function Start-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        try {
            $sanitizedPackage = ConvertTo-ValidAdbStringArgument $package
            Invoke-AdbExpression -DeviceId $DeviceId -Command "shell monkey -p $sanitizedPackage -c android.intent.category.LAUNCHER 1" -Verbose:$VerbosePreference > $null
        }
        catch [AdbCommandException] {
            if ($_.Exception.Message.EndsWith('No activities found to run, monkey aborted.')) {
                throw $_
            }
        }
    }
}
