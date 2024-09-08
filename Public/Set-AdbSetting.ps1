function Set-AdbSetting {

    [CmdletBinding()]
    [OutputType([string[]])]
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
            $id | Invoke-AdbExpression -Command "shell settings put $namespaceLowercase $Key ""$Value"""
        }
    }
}
