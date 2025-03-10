function Stop-AdbService {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Intent')]
        [PSCustomObject] $Intent,

        [Parameter(Mandatory, ParameterSetName = 'ComponentName')]
        [string] $PackageName,

        [Parameter(Mandatory, ParameterSetName = 'ComponentName')]
        [string] $ServiceName
    )

    begin {
        switch ($PSCmdlet.ParameterSetName) {
            'Intent' {
                $adbArgs = $Intent.ToAdbArguments()
            }
            'ComponentName' {
                $adbArgs = "-n '$PackageName/$ServiceName'"
            }
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 19) {
                Write-Error "The device $id does not support stopping services. Only API level 19 or above are supported."
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell am stopservice $adbArgs" -Verbose:$VerbosePreference
        }
    }
}
