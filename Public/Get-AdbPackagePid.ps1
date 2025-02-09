function Get-AdbPackagePid {

    [OutputType([int[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $ApplicationId
    )

    process {
        foreach ($id in $DeviceId) {
            $processId = Invoke-AdbExpression -DeviceId $id -Command "shell pidof '$ApplicationId'" -Verbose:$VerbosePreference
            
            if ($processId) {
                [int] $processId
            }
            else { $null }
        }
    }
}
