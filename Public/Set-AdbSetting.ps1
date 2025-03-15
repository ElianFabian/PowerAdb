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
            # This is not a real restriction, we rely on this to proper parse key-value pairs in 'Get-AdbSetting -List'
            # this is the format: key=value
            Write-Error "Key '$Key' can't contain the character '='"
            return
        }

        $namespaceLowercase = switch ($Namespace) {
            "Global" { "global" }
            "System" { "system" }
            "Secure" { "secure" }
        }

        $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 17
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell settings put $namespaceLowercase '$Key' '$sanitizedValue'" -Verbose:$VerbosePreference
        }
    }
}

# In order to make this work for System and Secure namespaces, enable
# "Disable permission monitoring" in Developer options. https://stackoverflow.com/a/72949330/18418162
