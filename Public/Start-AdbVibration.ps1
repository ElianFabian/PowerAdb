function Start-AdbVibration {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Synced')]
    param (
        [string] $SerialNumber,

        # Simple vibration that works across all API levels
        [Parameter(Mandatory, ParameterSetName = 'OneShot')]
        [uint32] $OneShotDuration,

        [Parameter(Mandatory, ParameterSetName = 'Synced')]
        [PSCustomObject] $Synced,

        # Waveform vibrations with repeating index don't work with combined
        [Parameter(Mandatory, ParameterSetName = 'Combined')]
        [scriptblock] $Combined,

        # Waveform vibrations with repeating index don't work with sequential
        [Parameter(Mandatory, ParameterSetName = 'Sequential')]
        [scriptblock] $Sequential,

        # 14,15,18,19, and 20 are the only values that work, at least on Pixel 8 Pro API 35
        [Parameter(Mandatory, ParameterSetName = 'Feedback')]
        [uint32] $Feedback,

        # https://cs.android.com/android/platform/superproject/main/+/main:frameworks/base/core/java/android/os/vibrator/persistence/VibrationXmlParser.java;l=307;drc=61197364367c9e404c7da6900658f1b16c42d0da;bpv=0;bpt=1
        # https://cs.android.com/android/platform/superproject/main/+/main:frameworks/base/core/java/com/android/internal/vibrator/persistence/XmlConstants.java;drc=61197364367c9e404c7da6900658f1b16c42d0da;bpv=0;bpt=1;l=39
        [Parameter(Mandatory, ParameterSetName = 'Xml')]
        [string] $Xml,

        [switch] $DontWait,

        # Ignore Do Not Disturb setting.
        # NOTES: At least on Pixel 8 Pro API 35, when the device is in Do Not Disturb mode, the vibration still works.
        [switch] $Force,

        [string] $Description
    )

    # NOTES: In some devices (e.g. Realme 6 API 30, and Xiaomi Mi MIX 2S API 29) the vibrator command does not seem to work

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 26

    if ($Combined) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 31 -FeatureName "$($MyInvocation.MyCommand.Name) -Combined"
    }
    if ($Synced) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 31 -FeatureName "$($MyInvocation.MyCommand.Name) -Syn$Synced"
    }
    if ($Sequential) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 31 -FeatureName "$($MyInvocation.MyCommand.Name) -Sequential"
    }
    if ($DontWait) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 33 -FeatureName "$($MyInvocation.MyCommand.Name) -DontWait"
    }
    if ($Feedback) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 35 -FeatureName "$($MyInvocation.MyCommand.Name) -Feedback"
    }
    if ($Xml) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 35 -FeatureName "$($MyInvocation.MyCommand.Name) -Xml"
    }

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false

    if ($apiLevel -ge 31) {
        if ($DontWait) {
            $dontWaitArg = ' -B'
        }
        if ($Force) {
            $forceArg = ' -f'
        }
        if ($Description) {
            $descriptionArg = " -d $(ConvertTo-ValidAdbStringArgument $Description)"
        }
    }
    else {
        if ($Description) {
            $descriptionArg = " $(ConvertTo-ValidAdbStringArgument $Description)"
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'OneShot' {
            if ($apiLevel -ge 31) {
                Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager synced oneshot$forceArg$descriptionAr $OneShotDuration" -Verbose:$VerbosePreference
            }
            else {
                Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator vibrate$forceArg $OneShotDuration$descriptionArg" -Verbose:$VerbosePreference
            }
        }
        'Synced' {
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager synced$forceArg$descriptionArg$dontWaitArg$($Synced.ToAdbArguments())" -Verbose:$VerbosePreference
        }
        'Combined' {
            $combinedStr = ($Combined.Invoke() | ForEach-Object { $_.ToAdbArguments() }) -join ''
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager combined$forceArg$descriptionArg$dontWaitArg$combinedStr" -Verbose:$VerbosePreference
        }
        'Sequential' {
            $sequentialStr = ($Sequential.Invoke() | ForEach-Object { $_.ToAdbArguments() }) -join ''
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager sequential$forceArg$descriptionArg$dontWaitArg$sequentialStr" -Verbose:$VerbosePreference
        }
        'Feedback' {
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager feedback$forceArg$descriptionArg$dontWaitArg $Feedback" -Verbose:$VerbosePreference
        }
        'Xml' {
            $sanitizedXml = ConvertTo-ValidAdbStringArgument $Xml
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager xml$forceArg$descriptionArg$dontWaitArg $sanitizedXml" -Verbose:$VerbosePreference
        }
    }
}
