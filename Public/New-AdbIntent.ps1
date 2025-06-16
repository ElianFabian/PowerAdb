# https://developer.android.com/tools/adb#IntentSpec
function New-AdbIntent {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $Action = $null,

        # The user is responsible for properly encoding the URI
        [uri] $Data = $null,

        [string] $MimeType = $null,

        [string] $Identifier = $null,

        [string[]] $Category = $null,

        [scriptblock] $Extras = $null,

        [int[]] $Flag = 0,

        [string[]] $NamedFlag,

        [switch] $Selector,

        [string] $PackageName = $null,

        [string] $ComponentClassName = $null,

        # Ignores arguments that aren't supported for the current API level
        [switch] $IgnoredUnsupportedFeatures
    )

    if ($Selector.IsPresent -and (-not $Data -or -not $MimeType)) {
        throw "The -Selector parameter can only be used when both -Data and -MimeType are set."
    }

    $intent = [PSCustomObject] @{
        Action                     = $Action
        Data                       = $Data
        MimeType                   = $MimeType
        Identifier                 = $Identifier
        Category                   = $Category
        Flags                      = GetCombinedFlags $Flag
        Selector                   = $Selector
        IgnoredUnsupportedFeatures = $IgnoredUnsupportedFeatures
    }

    if ($Extras) {
        $intent | Add-Member -MemberType NoteProperty -Name Extras -Value $Extras
    }
    if ($NamedFlag) {
        $intent | Add-Member -MemberType NoteProperty -Name NamedFlags -Value $NamedFlag
    }
    if ($PackageName) {
        $intent | Add-Member -MemberType NoteProperty -Name PackageName -Value $PackageName
    }
    if ($ComponentClassName) {
        $intent | Add-Member -MemberType NoteProperty -Name ComponentClassName -Value $ComponentClassName
    }
    if ($PackageName -and $ComponentClassName) {
        $componentName = "$PackageName/$ComponentClassName"
        $intent | Add-Member -MemberType NoteProperty -Name ComponentName -Value $componentName
    }

    $intent | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {

        param (
            [string] $DeviceId
        )

        $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false

        $adbArguments = ""
        if ($this.Action) {
            $adbArguments += " -a $(ConvertTo-ValidAdbStringArgument $this.Action)"
        }
        if ($this.Data) {
            $adbArguments += " -d $(ConvertTo-ValidAdbStringArgument $this.Data)"
        }
        if ($this.MimeType) {
            $adbArguments += " -t $(ConvertTo-ValidAdbStringArgument $this.MimeType)"
        }
        if ($this.Identifier -and ($this.IgnoredUnsupportedFeatures -and $apiLevel -gt 28 -or -not $this.IgnoredUnsupportedFeatures)) {
            $adbArguments += " -i $(ConvertTo-ValidAdbStringArgument $this.Identifier)"
        }
        if ($this.Category) {
            $adbArguments += " $($this.Category | ForEach-Object { "-c $(ConvertTo-ValidAdbStringArgument $_)" })"
        }
        if ($this.Flags) {
            $adbArguments += " -f 0x$($this.Flags.ToString('x8'))"
        }
        if ($this.Extras) {
            $thresholds = @{
                StringArray     = 21
                StringArrayList = 23
                IntArray        = 23
                IntArrayList    = 23
                LongArray       = 23
                LongArrayList   = 23
                FloatArray      = 23
                FloatArrayList  = 23
                Double          = 33
                DoubleArray     = 33
                DoubleArrayList = 33
            }

            $this.Extras.Invoke() | Where-Object {
                -not $this.IgnoredUnsupportedFeatures -or (-not $thresholds.ContainsKey($_.Type) -or ($thresholds.ContainsKey($_.Type) -and $apiLevel -ge $thresholds[$_.Type]))
            } `
            | ForEach-Object {
                $adbArguments += " $($_.ToAdbArguments($DeviceId))"
            }
        }
        if ($this.NamedFlags) {
            $validNamedFlags = Get-IntentNamedFlag -ApiLevel $apiLevel
            foreach ($flag in $this.NamedFlags) {
                if ($this.IgnoredUnsupportedFeatures -and $flag -notin $validNamedFlags) {
                    continue
                }
                $adbArguments += " --$flag"
            }
        }
        if ($this.Selector) {
            $adbArguments += " --selector"
        }

        if ($this.PackageName -and -not $this.ComponentName) {
            $adbArguments += " $(ConvertTo-ValidAdbStringArgument $this.PackageName)"
        }
        elseif ($this.ComponentName) {
            $adbArguments += " $(ConvertTo-ValidAdbStringArgument $this.ComponentName)"
        }

        $adbArguments
    }

    $intent | Add-Member -MemberType ScriptProperty -Name HexFlags -Value { "0x$($this.Flags.ToString('x8'))" }
    $intent | Add-Member -MemberType ScriptProperty -Name FlagsArray -Value {
        $flags = $this.Flags
        0..31 | ForEach-Object {
            $bit = 1 -shl $_
            if ($flags -band $bit) {
                $bit
            }
        }
    }
    $intent | Add-Member -MemberType ScriptProperty -Name HexFlagsArray -Value {
        $flags = $this.Flags
        0..31 | ForEach-Object {
            $bit = 1 -shl $_
            if ($flags -band $bit) {
                "0x$($bit.ToString('x8'))"
            }
        }
    }

    return $intent
}



function GetCombinedFlags {

    [OutputType([int])]
    param ([int[]] $flags)

    if ($flags.Count -eq 1) {
        return $flags[0]
    }

    [int] $combined = 0
    foreach ($flag in $flags) {
        $combined = $combined -bor $flag
    }

    return $combined
}
