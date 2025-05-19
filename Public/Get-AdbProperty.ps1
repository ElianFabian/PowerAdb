function Get-AdbProperty {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([string[]], ParameterSetName = "Default")]
    [OutputType([PSCustomObject[]], ParameterSetName = "List")]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [string[]] $Name,

        # Fast query of multiple values
        [Parameter(ParameterSetName = "Default")]
        [switch] $QueryFromList,

        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List
    )

    if ($List) {
        return Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell getprop' -Verbose:$VerbosePreference `
        | Select-String -Pattern "\[(.+)\]: \[(.*)\]" -AllMatches `
        | Select-Object -ExpandProperty Matches `
        | ForEach-Object {
            [PSCustomObject]@{
                Name  = $_.Groups[1].Value
                Value = $_.Groups[2].Value
            }
        }
    }

    if ($QueryFromList) {
        $properties = Get-AdbProperty -DeviceId $DeviceId -List -Verbose:$VerbosePreference
        $targetProperties = foreach ($propName in $Name) {
            $properties | Where-Object {
                $_.Name -ceq $propName
            } `
            | Select-Object -First 1
        }

        $targetProperties | Where-Object { $_.Name -cin $Name } `
        | Select-Object -ExpandProperty Value
    }
    else {
        $Name | ForEach-Object {
            if ($_.Contains(" ")) {
                Write-Error "Property name '$_' can't contain space characters"
                return
            }

            $isImmutable = Test-ImmutableProperty $_
            if ($isImmutable) {
                if (Test-CacheValue -DeviceId $DeviceId -Key $_) {
                    Get-CacheValue -DeviceId $DeviceId -Key $_ -Verbose:$VerbosePreference
                }
                else {
                    $sanitizedPropertyName = ConvertTo-ValidAdbStringArgument $_
                    $value = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell getprop $sanitizedPropertyName" -Verbose:$VerbosePreference | Out-String -NoNewline
                    Set-CacheValue -DeviceId $DeviceId -Key $_ -Value $value
                    $value
                }
            }
            else {
                $sanitizedPropertyName = ConvertTo-ValidAdbStringArgument $_
                Invoke-AdbExpression -DeviceId $DeviceId -Command "shell getprop $sanitizedPropertyName" -Verbose:$VerbosePreference | Out-String -NoNewline
            }
        }
    }
}
