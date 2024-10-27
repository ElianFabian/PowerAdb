function Set-AdbSetting {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet('Global', 'System', 'Secure')]
        [string] $Namespace,

        [Parameter(Mandatory)]
        [string] $Key,

        [Parameter(Mandatory)]
        [string] $Value
    )

    begin {
        if ($Key.Contains(' ')) {
            Write-Error "Key '$Key' can't contain space characters"
            return
        }
        if ($Key.Contains('=')) {
            # This is not a real restriction, we rely on this to proper parse key-value pairs in settings
            # this is the format: key=value
            Write-Error "Key '$Key' can't contain the character '='"
            return
        }

        $namespaceLowercase = $Namespace.ToLower()
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-Error "Settings is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 17 and above are supported."
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell settings put $namespaceLowercase '$Key' '$Value'" -Verbose:$VerbosePreference
        }
    }
}
