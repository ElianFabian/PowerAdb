function Get-AdbPackagePid {

    [OutputType([int[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $PackageName
    )

    process {
        foreach ($id in $DeviceId) {
            $processId = Invoke-AdbExpression -DeviceId $id -Command "shell pidof '$PackageName'" -Verbose:$VerbosePreference
            
            if ($processId) {
                [int] $processId
            }
            else { $null }
        }
    }
}
