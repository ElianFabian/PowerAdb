function Get-AdbAppVersionName {

    [OutputType([string[]])]
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
                | Select-String -Pattern "versionName=(.+)" `
                | Select-Object -ExpandProperty Matches -First 1 `
                | ForEach-Object { $_.Groups[1].Value }
            }
        }
    }
}
