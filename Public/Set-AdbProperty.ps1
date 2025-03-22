function Set-AdbProperty {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Name,

        [AllowEmptyString()]
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
            Invoke-AdbExpression -DeviceId $id -Command "shell setprop $Name $sanitizedValue" -Verbose:$VerbosePreference
        }
    }
}
