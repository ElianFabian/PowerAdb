function Set-AdbProperty {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Value
    )

    begin {
        if ($Name.Contains(" ")) {
            Write-Error "Property name '$Name' can't contain space characters"
            return
        }

        $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value
    }

    process {
        foreach ($id in $DeviceId) {
            $deviceProperties = adb -s $id shell getprop `
            | Out-String -Stream `
            | Select-String -Pattern "\[(.+)\]:" -AllMatches `
            | Select-Object -ExpandProperty Matches `
            | ForEach-Object { $_.Groups[1].Value } `
            | Where-Object { -not $_.StartsWith("debug.") }

            if ($Name -notin $deviceProperties -and -not $Name.StartsWith("debug.")) {
                Write-Error "Custom property '$Name' must start with 'debug.'"
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell setprop $Name $sanitizedValue" -Verbose:$VerbosePreference
        }
    }
}
