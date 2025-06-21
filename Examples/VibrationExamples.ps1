Start-AdbVibration -Synced (
    New-AdbOneShotVibration -DurationMilliseconds 5000 -Amplitude 255 -DelayMilliseconds 0
)

Start-AdbVibration -Synced (
    New-AdbPrimitiveVibration -Type (1..100 | ForEach-Object { 'PRIMITIVE_CLICK' }) -DelayMilliseconds 0
) -Verbose

Start-AdbVibration -Synced (
    New-AdbWaveFormVibration -Continuous {
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 255
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 100
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 200
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 255
    }
) -Verbose

Start-AdbVibration -Synced (
    New-AdbWaveFormVibration -Continuous -RepeatAtIndex 0 {
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 255
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 100
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 200
        New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 255
    }
) -Verbose

$xml = @"
<vibration-effect>
    <waveform-effect>
        <waveform-entry durationMs="1000" amplitude="100"/>
        <waveform-entry durationMs="50" amplitude="100"/>
        <waveform-entry durationMs="50" amplitude="100"/>
        <waveform-entry durationMs="50" amplitude="100"/>
        <waveform-entry durationMs="30" amplitude="255" />
        <waveform-entry durationMs="30" amplitude="255" />
        <waveform-entry durationMs="70" amplitude="200"/>
        <waveform-entry durationMs="70" amplitude="100"/>
        <waveform-entry durationMs="70" amplitude="100"/>
        <waveform-entry durationMs="70" amplitude="50"/>
        <waveform-entry durationMs="70" amplitude="50"/>
        <waveform-entry durationMs="70" amplitude="50"/>
    </waveform-effect>
</vibration-effect>
"@

Start-AdbVibration -Xml $xml -Verbose

Start-AdbVibration -Sequential {
    New-AdbVibratorVibration -Id 0 {
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 255 -DelayMilliseconds 100
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 100 -DelayMilliseconds 0
        New-AdbWaveFormVibration -Continuous {
            New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 255
            New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 0
        }
        New-AdbPrebakedVibration -Effect 'CLICK'
        New-AdbPrebakedVibration -Effect 'DOUBLE_CLICK'
        New-AdbPrebakedVibration -Effect 'DOUBLE_CLICK'
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 255 -DelayMilliseconds 250
        New-AdbPrebakedVibration -Effect 'TICK' -DelayMilliseconds 100
        New-AdbPrebakedVibration -Effect 'TICK'
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 255 -DelayMilliseconds 250
        New-AdbPrimitiveVibration -Type 'PRIMITIVE_CLICK', 'PRIMITIVE_CLICK', 'PRIMITIVE_THUD' -DelayMilliseconds 1000
    }
} -Verbose

Start-AdbVibration -Combined {
    New-AdbVibratorVibration -Id 0 {
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 255 -DelayMilliseconds 100
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 100 -DelayMilliseconds 0
        New-AdbWaveFormVibration -Continuous {
            New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 255
            New-AdbWaveFormVibrationStep -DurationMilliseconds 1000 -Amplitude 0
        }
        New-AdbPrebakedVibration -Effect 'CLICK'
        New-AdbPrebakedVibration -Effect 'DOUBLE_CLICK'
        New-AdbPrebakedVibration -Effect 'DOUBLE_CLICK'
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 255 -DelayMilliseconds 250
        New-AdbPrebakedVibration -Effect 'TICK' -DelayMilliseconds 100
        New-AdbPrebakedVibration -Effect 'TICK'
        New-AdbOneShotVibration -DurationMilliseconds 500 -Amplitude 255 -DelayMilliseconds 250
        New-AdbPrimitiveVibration -Type 'PRIMITIVE_CLICK', 'PRIMITIVE_CLICK', 'PRIMITIVE_THUD' -DelayMilliseconds 1000
    }
} -Verbose
