# https://developer.android.com/tools/adb#IntentSpec
function New-AdbIntent {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $Action = $null,

        [uri] $Data = $null,

        [string] $Type = $null,

        [string] $Identifier = $null,

        [string[]] $Category = $null,

        [string] $ApplicationId = $null,

        [string] $ComponentClassName = $null,

        [int] $Flags = 0,

        [switch] $Selector,

        [scriptblock] $Extras = $null
    )

    if ($Selector.IsPresent -and (-not $Data -or -not $Type)) {
        throw "The -Selector parameter can only be used when both -Data and -Type are set."
    }

    $intent = [PSCustomObject] @{
        Action     = $Action
        Data       = $Data
        Type       = $Type
        Identifier = $Identifier
        Category   = $Category
        Flags      = $Flags
        Selector   = $Selector
    }

    if ($Extras) {
        $intent | Add-Member -MemberType NoteProperty -Name Extras -Value ($Extras.Invoke())
    }
    if ($ApplicationId -and $ComponentClassName) {
        $componentName = "$ApplicationId/$ComponentClassName"
        $intent | Add-Member -MemberType NoteProperty -Name ComponentName -Value $componentName
    }
    elseif ($ApplicationId) {
        $intent | Add-Member -MemberType NoteProperty -Name ApplicationId -Value $ApplicationId
    }

    $intent | Add-Member -MemberType ScriptMethod -Name ToAdbArguments -Value {
        $adbArguments = ""
        if ($this.Action) {
            $adbArguments += " -a '$($this.Action)'"
        }
        if ($this.Data) {
            $adbArguments += " -d '$($this.Data)'"
        }
        if ($this.Type) {
            $adbArguments += " -t '$($this.Type)'"
        }
        if ($this.Identifier) {
            $adbArguments += " -i '$($this.Identifier)'"
        }
        if ($this.Category) {
            $adbArguments += " $($this.Category | ForEach-Object { "-c '$_'" })"
        }
        if ($this.ComponentName) {
            $adbArguments += " -n '$($this.ComponentName)'"
        }
        if ($this.Flags) {
            $adbArguments += " -f 0x$($this.Flags.ToString('x8'))"
        }
        if ($this.Extras) {
            $this.Extras | ForEach-Object {
                $adbArguments += " $($_.ToAdbArguments())"
            }
        }
        if ($this.Selector) {
            $adbArguments += " --selector"
        }

        if ($this.ApplicationId -and -not $this.ComponentName) {
            $adbArguments += " $($this.ApplicationId)"
        }

        $adbArguments.Trim()
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
