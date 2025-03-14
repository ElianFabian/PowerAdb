function New-AdbBundlePair {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Key,

        [Parameter(Mandatory, ParameterSetName = 'String')]
        [string] $String,

        [Parameter(Mandatory, ParameterSetName = 'Boolean')]
        [bool] $Boolean,

        [Parameter(Mandatory, ParameterSetName = 'Int')]
        [int] $Int,

        [Parameter(Mandatory, ParameterSetName = 'Long')]
        [long] $Long,

        [Parameter(Mandatory, ParameterSetName = 'Float')]
        [float] $Float,

        [Parameter(Mandatory, ParameterSetName = 'Uri')]
        [uri] $Uri,

        [Parameter(Mandatory, ParameterSetName = 'ComponentName')]
        [string] $PackageName,

        [Parameter(Mandatory, ParameterSetName = 'ComponentName')]
        [string] $ClassName,

        [Parameter(Mandatory, ParameterSetName = 'IntArray')]
        [int[]] $IntArray,

        [Parameter(Mandatory, ParameterSetName = 'IntArrayList')]
        [int[]] $IntArrayList,

        [Parameter(Mandatory, ParameterSetName = 'LongArray')]
        [long[]] $LongArray,

        [Parameter(Mandatory, ParameterSetName = 'LongArrayList')]
        [long[]] $LongArrayList,

        [Parameter(Mandatory, ParameterSetName = 'FloatArray')]
        [float[]] $FloatArray,

        [Parameter(Mandatory, ParameterSetName = 'FloatArrayList')]
        [float[]] $FloatArrayList,

        [Parameter(Mandatory, ParameterSetName = 'StringArray')]
        [string[]] $StringArray,

        [Parameter(Mandatory, ParameterSetName = 'StringArrayList')]
        [string[]] $StringArrayList
    )

    $pair = [PSCustomObject]@{
        Key  = $Key
        Type = $PSCmdlet.ParameterSetName
    }

    switch ($PSCmdlet.ParameterSetName) {
        'String' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $String
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedValue = ConvertTo-ValidAdbStringArgument $this.Value
                "--es '$($this.Key)' '""$sanitizedValue""'"
            }
        }
        'Boolean' {
            $booleanStr = if ($Boolean) { 'true' } else { 'false' }
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $booleanStr
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--ez '$($this.Key)' $($this.Value)" }
        }
        'Int' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Int
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--ei '$($this.Key)' $($this.Value)" }
        }
        'Long' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Long
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--el '$($this.Key)' $($this.Value)" }
        }
        'Float' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Float
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                "--ef '$($this.Key)' $($this.Value.ToString([System.Globalization.CultureInfo]::InvariantCulture))"
            }
        }
        'Uri' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Uri
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--eu '$($this.Key)' '$($this.Value)'" }
        }
        'ComponentName' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value "$PackageName/$ClassName"
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--ecn '$($this.Key)' '$($this.Value)'" }
        }
        'IntArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $IntArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--eia '$($this.Key)' $($this.Value -join ',')" }
        }
        'IntArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $IntArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--eial '$($this.Key)' $($this.Value -join ',')" }
        }
        'LongArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $LongArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--ela '$($this.Key)' $($this.Value -join ',')" }
        }
        'LongArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $LongArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value { "--elal '$($this.Key)' $($this.Value -join ',')" }
        }
        'FloatArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $FloatArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                "--efa '$($this.Key)' $(($this.Value | ForEach-Object { $_.ToString([System.Globalization.CultureInfo]::InvariantCulture) }) -join ',')"
            }
        }
        'FloatArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $FloatArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                "--efal '$($this.Key)' $(($this.Value | ForEach-Object { $_.ToString([System.Globalization.CultureInfo]::InvariantCulture) }) -join ',')"
            }
        }
        'StringArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $StringArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedValues = $this.Value | ForEach-Object { ConvertTo-ValidAdbStringArgument $_ }
                $sanitizedValuesStr = ($sanitizedValues | ForEach-Object { "''$_''" }) -join ','
                "--esa '$($this.Key)' '""$sanitizedValuesStr""'"
            }
        }
        'StringArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $StringArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedValues = $this.Value | ForEach-Object { ConvertTo-ValidAdbStringArgument $_ }
                $sanitizedValuesStr = ($sanitizedValues | ForEach-Object { "''$_''" }) -join ','
                "--esal '$($this.Key)' '""$sanitizedValuesStr""'"
            }
        }
    }

    return $pair
}
