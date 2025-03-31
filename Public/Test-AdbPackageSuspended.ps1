function Test-AdbPackageSuspended {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$package'" -Verbose:$VerbosePreference | Out-String

                $rawData.Contains('suspended=true')
            }
        }
    }
}
