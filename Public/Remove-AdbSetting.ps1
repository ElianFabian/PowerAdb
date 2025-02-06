function Remove-AdbSetting {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("Global", "System", "Secure")]
        [string] $Namespace,

        [Parameter(Mandatory)]
        [string] $Key
    )

    begin {
        $Key = [string] $PSBoundParameters['Key']
        if ($Key.Contains(" ")) {
            Write-Error "Key '$Key' can't contain space characters"
            return
        }

        $namespaceLowercase = switch ($Namespace) {
            "Global" { "global" }
            "System" { "system" }
            "Secure" { "secure" }
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 21) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 21
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell settings delete $namespaceLowercase $Key" -Verbose:$VerbosePreference
        }
    }
}
