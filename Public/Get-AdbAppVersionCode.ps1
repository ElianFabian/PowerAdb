function Get-AdbAppVersionCode {

    [OutputType([int[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" `
                | Select-String -Pattern "versionCode=(\d+)" `
                | Select-Object -ExpandProperty Matches -First 1 `
                | ForEach-Object { [int] $_.Groups[1].Value }
            }
        }
    }
}
