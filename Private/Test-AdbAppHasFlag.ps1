function Test-AdbAppHasFlag {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId,

        [Parameter(Mandatory)]
        [string] $Flag
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                # For more information: https://developer.android.com/guide/topics/manifest/application-element
                Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" `
                | Select-String -Pattern "flags=\[\s.+\s\]" `
                | Select-Object -ExpandProperty Matches -First 1 `
                | ForEach-Object { $_.Value.Contains($Flag) }
            }
        }
    }
}
