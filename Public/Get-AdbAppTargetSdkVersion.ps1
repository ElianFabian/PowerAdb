function Get-AdbAppTargetSdkVersion {

    [OutputType([uint32[]])]
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
                | Select-String -Pattern "targetSdk=(\d+)" `
                | Select-Object -ExpandProperty Matches -First 1 `
                | ForEach-Object { [uint32] $_.Groups[1].Value }
            }
        }
    }
}
