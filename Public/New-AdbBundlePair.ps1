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
        [string] $ComponentName,

        [Parameter(Mandatory, ParameterSetName = 'IntArray')]
        [int[]] $IntArray,

        [Parameter(Mandatory, ParameterSetName = 'LongArray')]
        [long[]] $LongArray,

        [Parameter(Mandatory, ParameterSetName = 'FloatArray')]
        [float[]] $FloatArray,

        [Parameter(Mandatory, ParameterSetName = 'StringArray')]
        [string[]] $StringArray
    )

    $pair = [PSCustomObject]@{
        Key  = $Key
        Type = $PSCmdlet.ParameterSetName
    }

    switch ($PSCmdlet.ParameterSetName) {
        'String' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $String
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--es '$($pair.Key)' '$($pair.Value)'"
        }
        'Boolean' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Boolean
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--ez '$($pair.Key)' $($pair.Value)"
        }
        'Int' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Int
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--ei '$($pair.Key)' $($pair.Value)"
        }
        'Long' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Long
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--el '$($pair.Key)' $($pair.Value)"
        }
        'Float' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Float
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--ef '$($pair.Key)' $($pair.Value)"
        }
        'Uri' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $Uri
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--eu '$($pair.Key)' $($pair.Value)"
        }
        'ComponentName' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $ComponentName
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--ecn '$($pair.Key)' $($pair.Value)"
        }
        'IntArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $IntArray
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--eia '$($pair.Key)' $($pair.Value -join ',')"
        }
        'LongArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $LongArray
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--ela '$($pair.Key)' $($pair.Value -join ',')"
        }
        'FloatArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $FloatArray
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--efa '$($pair.Key)' $($pair.Value -join ',')"
        }
        'StringArray' {
            $pair | Add-Member -MemberType NoteProperty -Name Value -Value $StringArray
            $pair | Add-Member -MemberType NoteProperty -Name AdbArgument -Value "--esa '$($pair.Key)' $(($pair.Value | ForEach-Object { "'$_'"}) -join ',')"
        }
    }

    return $pair
}
