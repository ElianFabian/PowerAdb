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

        [Parameter(Mandatory, ParameterSetName = 'Double')]
        [double] $Double,

        # The user is responsible for properly encoding the URI
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

        [Parameter(Mandatory, ParameterSetName = 'DoubleArray')]
        [double[]] $DoubleArray,

        [Parameter(Mandatory, ParameterSetName = 'DoubleArrayList')]
        [double[]] $DoubleArrayList,

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
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                $sanitizedValue = ConvertTo-ValidAdbStringArgument $this.Value

                "--es $sanitizedKey $sanitizedValue"
            }
        }
        'Boolean' {
            $booleanStr = if ($Boolean) { 'true' } else { 'false' }
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $booleanStr
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--ez $sanitizedKey $($this.Value)"
            }
        }
        'Int' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Int
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--ei $sanitizedKey $($this.Value)"
            }
        }
        'Long' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Long
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--el $sanitizedKey $($this.Value)"
            }
        }
        'Float' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Float
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--ef $sanitizedKey $($this.Value.ToString([System.Globalization.CultureInfo]::InvariantCulture))"
            }
        }
        'Double' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Float
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--ed $sanitizedKey $($this.Value.ToString([System.Globalization.CultureInfo]::InvariantCulture))"
            }
        }
        'Uri' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Uri
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                $sanitizedValue = ConvertTo-ValidAdbStringArgument $this.Value
                "--eu $sanitizedKey $sanitizedValue"
            }
        }
        'ComponentName' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value "$PackageName/$ClassName"
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                $sanitizedValue = ConvertTo-ValidAdbStringArgument $this.Value
                "--ecn $sanitizedKey $sanitizedValue"
            }
        }
        'IntArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $IntArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--eia $sanitizedKey $($this.Value -join ',')"
            }
        }
        'IntArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $IntArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--eial $sanitizedKey $($this.Value -join ',')"
            }
        }
        'LongArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $LongArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--ela $sanitizedKey $($this.Value -join ',')"
            }
        }
        'LongArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $LongArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--elal $sanitizedKey $($this.Value -join ',')"
            }
        }
        'FloatArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $FloatArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--efa $sanitizedKey $(($this.Value | ForEach-Object { $_.ToString([System.Globalization.CultureInfo]::InvariantCulture) }) -join ',')"
            }
        }
        'FloatArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $FloatArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--efal $sanitizedKey $(($this.Value | ForEach-Object { $_.ToString([System.Globalization.CultureInfo]::InvariantCulture) }) -join ',')"
            }
        }
        'DoubleArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $DoubleArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--eda $sanitizedKey $(($this.Value | ForEach-Object { $_.ToString([System.Globalization.CultureInfo]::InvariantCulture) }) -join ',')"
            }
        }
        'DoubleArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $DoubleArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                "--edal $sanitizedKey $(($this.Value | ForEach-Object { $_.ToString([System.Globalization.CultureInfo]::InvariantCulture) }) -join ',')"
            }
        }
        'StringArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $StringArray
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                $sanitizedValues = $this.Value | ForEach-Object { ConvertTo-ValidAdbStringArgument $_ }
                $sanitizedValuesStr = ($sanitizedValues | ForEach-Object { $_ }) -join ','

                "--esa $sanitizedKey $sanitizedValuesStr"
            }
        }
        'StringArrayList' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $StringArrayList
            $pair | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
                $sanitizedKey = ConvertTo-ValidAdbStringArgument $this.Key
                $sanitizedValues = $this.Value | ForEach-Object { ConvertTo-ValidAdbStringArgument $_ }
                $sanitizedValuesStr = ($sanitizedValues | ForEach-Object { $_ }) -join ','

                "--esal $sanitizedKey $sanitizedValuesStr"
            }
        }
    }

    return $pair
}
