function Set-AdbProperty {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Name,

        # Custom properties starts with 'debug.'
        # New line characters are ignored
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value
    )

    if ($Name.Contains(" ")) {
        Write-Error "Property name '$Name' can't contain space characters" -ErrorAction Stop
    }

    $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell setprop '$Name' $sanitizedValue" -Verbose:$VerbosePreference
}
