function Get-AdbSetting {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("global", "system", "secure")]
        [string] $Namespace,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [string[]] $Name,

        # Fast query of multiple values
        # Be careful with this parameter, as it relies on the assumption that no key contains '='
        [Parameter(ParameterSetName = "Default")]
        [switch] $QueryFromList,

        # Be careful with this parameter, as it relies on the assumption that no key contains '='
        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List,

        [ValidateSet('Default', 'ContentProvider')]
        [string] $Type = 'Default'
    )

    if ($List) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -List"
    }
    elseif ($QueryFromList) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -QueryFromList"
    }
    else {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17
    }

    if ($List) {
        # There's not gaurantee that all settings will be propertly parsed since the output is not guaranteed to be in a specific format.
        # This will when:
        # - The setting name contains an equals symbol
        # - The setting value contains newline characters
        return Invoke-AdbExpression -DeviceId $DeviceId -Command "shell settings list $Namespace" -Verbose:$VerbosePreference `
        | ForEach-Object {
            $indexOfEqualsSymbol = $_.IndexOf('=')
            if ($indexOfEqualsSymbol -eq -1) {
                # It turns out that some settings have no equals symbol, so we just skip them
                return
            }
            $itemName = $_.Substring(0, $indexOfEqualsSymbol)
            $itemValue = $_.Substring($indexOfEqualsSymbol + 1)
            [PSCustomObject]@{
                Name  = $itemName
                Value = $itemValue
            }
        }
    }

    if ($QueryFromList) {
        $properties = Get-AdbSetting -DeviceId $DeviceId -Namespace $Namespace -List -Verbose:$VerbosePreference | Out-String
        $targetProperties = foreach ($propertyName in $Name) {
            $properties | Where-Object {
                $_.Name -ceq $propertyName
            } `
            | Select-Object -First 1
        }

        $targetProperties | Where-Object { $_.Name -cin $Name } `
        | Select-Object -ExpandProperty Value
    }
    else {
        $Name | ForEach-Object {
            Invoke-AdbExpression -DeviceId $DeviceId -Command "shell settings get $Namespace '$_'" -Verbose:$VerbosePreference | Out-String -NoNewline
        }
    }
}
