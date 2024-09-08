function Set-AdbProp {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PropertyName,

        [Parameter(Mandatory)]
        [string] $Value
    )

    begin {
        if ($PropertyName.Contains(" ")) {
            Write-Error "PropertyName '$PropertyName' can't contain space characters"
            return
        }
        if ($Value.Contains(" ")) {
            Write-Error "Value '$Value' can't contain space characters"
            return
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $deviceProperties = adb -s $id shell getprop
            | Out-String -Stream
            | Select-String -Pattern "\[(.+)\]:" -AllMatches
            | Select-Object -ExpandProperty Matches
            | ForEach-Object { $_.Groups[1].Value }
            | Where-Object { -not $_.StartsWith("debug.") }

            if ($PropertyName -notin $deviceProperties -and -not $PropertyName.StartsWith("debug.")) {
                Write-Error "Custom property '$PropertyName' must start with 'debug.'"
                return
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell setprop $PropertyName ""$Value"""
        }
    }
}
