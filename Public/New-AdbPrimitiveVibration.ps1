function New-AdbPrimitiveVibration {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [ValidateSet(
            'PRIMITIVE_NOOP',
            'PRIMITIVE_CLICK',
            'PRIMITIVE_THUD',
            'PRIMITIVE_SPIN',
            'PRIMITIVE_QUICK_RISE',
            'PRIMITIVE_SLOW_RISE',
            'PRIMITIVE_QUICK_FALL',
            'PRIMITIVE_TICK',
            'PRIMITIVE_LOW_TICK'
        )]
        [Parameter(Mandatory)]
        [string[]] $Type,

        [int] $DelayMilliseconds = 0
    )

    $output = [PSCustomObject]@{
        Type              = $Type
        DelayMilliseconds = $DelayMilliseconds
    }

    $output | Add-Member -MemberType ScriptProperty -Name 'TypeCode' -Value {
        # https://cs.android.com/android/platform/superproject/main/+/main:frameworks/base/core/java/android/os/VibrationEffect.java;l=1516;bpv=0;bpt=1
        switch ($this.Type) {
            'PRIMITIVE_NOOP' { 0 }
            'PRIMITIVE_CLICK' { 1 }
            'PRIMITIVE_THUD' { 2 }
            'PRIMITIVE_SPIN' { 3 }
            'PRIMITIVE_QUICK_RISE' { 4 }
            'PRIMITIVE_SLOW_RISE' { 5 }
            'PRIMITIVE_QUICK_FALL' { 6 }
            'PRIMITIVE_TICK' { 7 }
            'PRIMITIVE_LOW_TICK' { 8 }
            default { throw "Unknown primitive type: $($this.Type)" }
        }
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        return " primitives -w $($this.DelayMilliseconds) $($this.TypeCode)"
    }

    return $output
}
