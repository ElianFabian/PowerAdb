function New-AdbPrebakedVibration {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        # The ones that at least work on Pixel 8 Pro API 35 are:
        # - 'CLICK', 'DOUBLE_CLICK', 'TICK', 'POP', 'HEAVY_CLICK', 'TEXTURE_TICK'.
        [ValidateSet(
            'CLICK',
            'DOUBLE_CLICK',
            'TICK',
            'THUD',
            'POP',
            'HEAVY_CLICK',
            'RINGTONE_1',
            'RINGTONE_2',
            'RINGTONE_3',
            'RINGTONE_4',
            'RINGTONE_5',
            'RINGTONE_6',
            'RINGTONE_7',
            'RINGTONE_8',
            'RINGTONE_9',
            'RINGTONE_10',
            'RINGTONE_11',
            'RINGTONE_12',
            'RINGTONE_13',
            'RINGTONE_14',
            'RINGTONE_15',
            'TEXTURE_TICK'
        )]
        [Parameter(Mandatory)]
        [string] $Effect,

        [int] $DelayMilliseconds = 0,

        # I tested it with the ones that don't work on Pixel 8 Pro API 35, but this doesn't seem to do anything.
        [switch] $Fallback
    )

    $output = [PSCustomObject]@{
        Effect            = $Effect
        Fallback          = $Fallback.IsPresent
        DelayMilliseconds = $DelayMilliseconds
    }

    $output | Add-Member -MemberType ScriptProperty -Name 'EffectCode' -Value {
        # https://cs.android.com/android/platform/superproject/main/+/main:prebuilts/vndk/v30/arm64/include/generated-headers/hardware/interfaces/vibrator/aidl/android.hardware.vibrator-ndk_platform-source/gen/include/aidl/android/hardware/vibrator/Effect.h;l=17?q=Effect
        switch ($this.Effect) {
            'CLICK' { 0 }
            'DOUBLE_CLICK' { 1 }
            'TICK' { 2 }
            'THUD' { 3 }
            'POP' { 4 }
            'HEAVY_CLICK' { 5 }
            'RINGTONE_1' { 6 }
            'RINGTONE_2' { 7 }
            'RINGTONE_3' { 8 }
            'RINGTONE_4' { 9 }
            'RINGTONE_5' { 10 }
            'RINGTONE_6' { 11 }
            'RINGTONE_7' { 12 }
            'RINGTONE_8' { 13 }
            'RINGTONE_9' { 14 }
            'RINGTONE_10' { 15 }
            'RINGTONE_11' { 16 }
            'RINGTONE_12' { 17 }
            'RINGTONE_13' { 18 }
            'RINGTONE_14' { 19 }
            'RINGTONE_15' { 20 }
            'TEXTURE_TICK' { 21 }
            default { throw "Unknown effect: $($this.Effect)" }
        }
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        if ($this.Fallback) {
            $fallbackArg = ' -b'
        }
        return " prebaked -w $($this.DelayMilliseconds)$fallbackArg $($this.EffectCode)"
    }

    return $output
}
