$functionNames = Get-ChildItem -LiteralPath "$PSScriptRoot/Public/" -File `
| Where-Object { -not (& "$PSScriptRoot/Test-IncorrectFileFunction.ps1" -Path $_.FullName) } `
| Select-Object -ExpandProperty BaseName

Register-ArgumentCompleter `
    -CommandName (Get-Command -Name $functionNames) `
    -ParameterName DeviceId -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $WarningPreference = 'SilentlyContinue'

    Get-AdbDevice -Verbose:$false | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        $deviceName = Get-AdbDeviceName -DeviceId $_ -Verbose:$false
        $apiLevel = Get-AdbApiLevel -DeviceId $_ -Verbose:$false

        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            $_
            "$_ ($deviceName, $apiLevel)"
            'ParameterValue'
            "Device: $deviceName`nAPI level: $apiLevel"
        )
    }
}

$packageCompletion = {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    $WarningPreference = 'SilentlyContinue'

    $applicationIds = Get-AdbPackage -DeviceId $deviceId -Verbose:$false

    $startMatches = $applicationIds | Where-Object { $_ -like "$wordToComplete*" }
    $containMatches = $applicationIds | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" }

    @($startMatches) + @($containMatches)
}

Register-ArgumentCompleter -CommandName @(
    "Start-AdbApp"
    "Get-AdbAppPid"
    "Grant-AdbPermission"
    "Revoke-AdbPermission"
    "Start-AdbAppCrash"
    "Invoke-AdbDeepLink"
    "Stop-AdbApp"
    "Start-AdbAppProcessDeath"
    "Install-AdbApp"
    "Uninstall-AdbApp"
    "Clear-AdbAppInfo"
    "Get-AdbAppMinSdkVersion"
    "Get-AdbAppSha256Signature"
    "Get-AdbAppTargetSdkVersion"
    "Get-AdbAppVersionCode"
    "Get-AdbAppVersionName"
    "Get-AdbFileContent"
    "Test-AdbAppAllowClearUserData"
    "Test-AdbAppHasCode"
    "Test-AdbAppDebuggable"
    "Test-AdbAppTestOnly"
    "Test-AdbAppLargeHeap"
    "Get-AdbAppFirstInstallDate"
    "Get-AdbAppLastUpdateDate"
    "Get-AdbAppInfo"
    "Stop-AdbService"
) -ParameterName ApplicationId -ScriptBlock $packageCompletion

Register-ArgumentCompleter -CommandName @(
    "Test-AdbPath"
    "Get-AdbContent"
    "Get-AdbChildItem"
) -ParameterName RunAs -ScriptBlock $packageCompletion


Register-ArgumentCompleter -CommandName @(
    "Get-AdbProperty"
    "Set-AdbProperty"
) -ParameterName Name -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    $WarningPreference = 'SilentlyContinue'

    $deviceProperties = Get-AdbProperty -DeviceId $deviceId -List -Verbose:$false | Select-Object -ExpandProperty Name

    $startMatches = $deviceProperties | Where-Object { $_ -like "$wordToComplete*" }
    $containMatches = $deviceProperties | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" }
    $startMatches + $containMatches
}

Register-ArgumentCompleter -CommandName @(
    "Get-AdbSetting"
    "Set-AdbSetting"
    "Remove-AdbSetting"
) `
    -ParameterName Key -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']
    $namespace = $fakeBoundParameters['Namespace']

    $WarningPreference = 'SilentlyContinue'

    $keys = [string[]] (Get-AdbSetting -DeviceId $deviceId -Namespace $namespace -List -Verbose:$false | Select-Object -ExpandProperty Key)
    $startMatches = [string[]] ($keys | Where-Object { $_ -like "$wordToComplete*" })
    $containMatches = [string[]] ($keys | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" })

    $startMatches + $containMatches
}


$script:AdbKeyCodes = @(
    "UNKNOWN",
    "MENU",
    "SOFT_RIGHT",
    "HOME",
    "BACK",
    "CALL",
    "ENDCALL",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "STAR",
    "POUND",
    "DPAD_UP",
    "DPAD_DOWN",
    "DPAD_LEFT",
    "DPAD_RIGHT",
    "DPAD_CENTER",
    "VOLUME_UP",
    "VOLUME_DOWN",
    "POWER",
    "CAMERA",
    "CLEAR",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "COMMA",
    "PERIOD",
    "ALT_LEFT",
    "ALT_RIGHT",
    "CTRL_LEFT",
    "CTRL_RIGHT",
    "SHIFT_LEFT",
    "SHIFT_RIGHT",
    "TAB",
    "SPACE",
    "SYM",
    "EXPLORER",
    "ENVELOPE",
    "ENTER",
    "DEL",
    "GRAVE",
    "MINUS",
    "EQUALS",
    "LEFT_BRACKET",
    "RIGHT_BRACKET",
    "BACKSLASH",
    "SEMICOLON",
    "APOSTROPHE",
    "SLASH",
    "AT",
    "NUM",
    "HEADSETHOOK",
    "FOCUS",
    "PLUS",
    "MENU",
    "NOTIFICATION",
    "SEARCH",
    "ESCAPE",
    "BUTTON_START",
    "TAG_LAST_KEYCODE",
    "PAGE_UP",
    "PAGE_DOWN",
    "PASTE",
    "MOVE_HOME",
    "MOVE_END",
    "MEDIA_PLAY_PAUSE",
    "MEDIA_STOP",
    "MEDIA_NEXT",
    "MEDIA_PREVIOUS",
    "MEDIA_REWIND",
    "MEDIA_FAST_FORWARD",
    "MUTE",
    "PICTSYMBOLS"
)

Register-ArgumentCompleter -CommandName @(
    "Send-AdbKeyEvent"
) `
    -ParameterName KeyCode -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $script:AdbKeyCodes | Where-Object { $_ -like "$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName @(
    "Send-AdbKeyCombination"
) `
    -ParameterName KeyCodes -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $script:AdbKeyCodes | Where-Object { $_ -like "$wordToComplete*" }
}

$remotePathCompletion = {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']
    $runAs = $fakeBoundParameters['RunAs']
    if ($runAs) {
        $runAsCommand = " run-as '$runAs'"
    }

    $partiallyNormalizedWordToComplete = $wordToComplete.Trim("'").Replace('\', '/')
    $hasFinalSlash = $partiallyNormalizedWordToComplete.EndsWith('/')

    $normalizedWordToComplete = $partiallyNormalizedWordToComplete.Trim('/')

    $parentPath = if ([string]::IsNullOrWhiteSpace($normalizedWordToComplete)) {
        ''
    }
    elseif ($hasFinalSlash) {
        $normalizedWordToComplete
    }
    else {
        (Split-Path -Path $normalizedWordToComplete -Parent -Verbose:$false).Replace('\', '/').Trim('/')
    }
    $childPath = if ($hasFinalSlash) {
        ''
    }
    else {
        (Split-Path -Path $normalizedWordToComplete -Leaf -Verbose:$false).Replace('\', '/').Trim('/')
    }

    $WarningPreference = 'SilentlyContinue'

    $firstSlash = if ($runAs) { '' } else { '/' }

    # There's no good way to know if a symbolic link is a directory or a file that has performance issues
    # So, we aren't able to add a slash to the end of the directory, which would be a nice feature
    Invoke-AdbExpression -DeviceId $deviceId -Command "shell$runAsCommand ls '$parentPath'" -Verbose:$false `
    | ForEach-Object { $_.Trim() } `
    | Where-Object {
        $_ -like "$childPath*"
    } `
    | ForEach-Object {
        $finalPath = if ([string]::IsNullOrWhiteSpace($parentPath)) {
            "$firstSlash$_"
        }
        else { "$firstSlash$parentPath/$_" }
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            "'$finalPath'"
            "$_"
            'ParameterValue'
            "$finalPath"
        )
    }
}

Register-ArgumentCompleter -CommandName @(
    "Receive-AdbItem"
    "Send-AdbItem"
    "New-AdbItem"
    "Test-AdbPath"
    "Remove-AdbItem"
    "Move-AdbItem"
) -ParameterName LiteralRemotePath -ScriptBlock $remotePathCompletion

Register-ArgumentCompleter -CommandName @(
    "Get-AdbContent"
    "Get-AdbChildItem"
    "Set-AdbContent"
    "Add-AdbContent"
    "Copy-AdbItem"
    "Move-AdbItem"
) -ParameterName RemotePath -ScriptBlock $remotePathCompletion

Register-ArgumentCompleter -CommandName @(
    "Copy-AdbItem"
    "Move-AdbItem"
) -ParameterName RemoteDestination -ScriptBlock $remotePathCompletion

Register-ArgumentCompleter -CommandName @(
    "Start-AdbActivity"
) -ParameterName LiteralRemoteProfilerPath -ScriptBlock $remotePathCompletion
