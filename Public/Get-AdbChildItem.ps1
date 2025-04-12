function Get-AdbChildItem {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [string] $RemotePath,

        [switch] $Recurse,

        [string] $RunAs
    )

    if ($Recurse) {
        $recurseArg = " -R"
    }
    if ($RunAs) {
        $runAsCommand = " run-as '$RunAs'"
    }

    foreach ($path in $RemotePath) {
        if ($path) {
            $sanitizedRemotePathArg = " $(ConvertTo-ValidAdbStringArgument $path)"
        }

        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand ls$recurseArg$sanitizedRemotePathArg" -Verbose:$VerbosePreference `
        | Out-String -Stream `
        | Where-Object { -not $_.Contains(':') -and -not [string]::IsNullOrWhiteSpace($_) }
    }
}
