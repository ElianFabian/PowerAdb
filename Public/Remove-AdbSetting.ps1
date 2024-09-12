function Remove-AdbSetting {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("Global", "System", "Secure")]
        [string] $Namespace,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [string] $Key
    )

    begin {
        $Key = [string] $PSBoundParameters['Key']
        if ($Key.Contains(" ")) {
            Write-Error "Key '$Key' can't contain space characters"
            return
        }

        $namespaceLowercase = $Namespace.ToLower()
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 21) {
                Write-Error "Removing keys is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 21 and above are supported."
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell settings delete $namespaceLowercase $Key"
        }
    }
}
