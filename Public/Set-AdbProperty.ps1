function Set-AdbProperty {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $Name,

        # Custom properties starts with 'debug.'
        # New line characters are ignored
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value
    )

    foreach ($propertyName in $Name) {
        if ($propertyName.Contains("=")) {
            Write-Error "Property name '$propertyName' can't contain the character '='" -ErrorAction Stop
        }
    }

    $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value

    foreach ($propertyName in $Name) {
        $sanitizedPropertyName = ConvertTo-ValidAdbStringArgument $propertyName
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell setprop $sanitizedPropertyName $sanitizedValue" -Verbose:$VerbosePreference
    }
}
