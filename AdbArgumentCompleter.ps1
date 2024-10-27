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
    "Clear-AdbAppData"
    "Get-AdbAppMinSdkVersion"
    "Get-AdbAppSha256Signature"
    "Get-AdbAppTargetSdkVersion"
    "Get-AdbAppVersionCode"
    "Get-AdbAppVersionName"
    "Test-AdbAppAllowClearUserData"
    "Test-AdbAppHasCode"
    "Test-AdbAppDebuggable"
    "Test-AdbAppTestOnly"
    "Test-AdbAppLargeHeap"
) `
    -ParameterName ApplicationId -ScriptBlock {

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
    $startMatches + $containMatches
}

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
    "UNKNOWN", "MENU", "SOFT_RIGHT", "HOME",
    "BACK", "CALL", "ENDCALL",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "STAR", "POUND",
    "DPAD_UP", "DPAD_DOWN", "DPAD_LEFT", "DPAD_RIGHT", "DPAD_CENTER",
    "VOLUME_UP", "VOLUME_DOWN",
    "POWER", "CAMERA", "CLEAR",
    "A", "B", "C", "D",
    "E", "F", "G", "H",
    "I", "J", "K", "L",
    "M", "N", "O", "P",
    "Q", "R", "S", "T",
    "U", "V", "W", "X", "Y", "Z",
    "COMMA", "PERIOD",
    "ALT_LEFT", "ALT_RIGHT",
    "CTRL_LEFT", "CTRL_RIGHT",
    "SHIFT_LEFT", "SHIFT_RIGHT",
    "TAB", "SPACE", "SYM", "EXPLORER",
    "ENVELOPE", "ENTER", "DEL", "GRAVE",
    "MINUS", "EQUALS",
    "LEFT_BRACKET", "RIGHT_BRACKET",
    "BACKSLASH", "SEMICOLON", "APOSTROPHE", "SLASH", "AT", "NUM",
    "HEADSETHOOK", "FOCUS", "PLUS",
    "MENU", "NOTIFICATION", "SEARCH",
    "ESCAPE", "BUTTON_START",
    "TAG_LAST_KEYCODE",
    "PAGE_UP", "PAGE_DOWN",
    "PASTE"
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

Register-ArgumentCompleter -CommandName @(
    "Receive-AdbFile"
    "Send-AdbFile"
) `
    -ParameterName LiteralRemotePath -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    $normalizedWordToComplete = $wordToComplete.Trim("'").Replace('\', '/').Replace('//', "/")
    $hasFinalSlash = $normalizedWordToComplete.EndsWith('/')

    $parentPath = if ($hasFinalSlash) {
        $normalizedWordToComplete
    }
    else { (Split-Path -Path $normalizedWordToComplete -Parent -Verbose:$false).Replace('\', '/') }
    $childPath = if ($hasFinalSlash) {
        ''
    }
    else { (Split-Path -Path $normalizedWordToComplete -Leaf -Verbose:$false).Replace('\', '/') }

    $finalSlash = if ($hasFinalSlash) { '/' } else { '' }

    $WarningPreference = 'SilentlyContinue'

    Invoke-AdbExpression -DeviceId $deviceId -Command "shell ls '$parentPath'" -Verbose:$false `
    | ForEach-Object { $_.Trim() } `
    | Where-Object {
        $_ -like "$childPath*"
    } `
    | ForEach-Object {
        $finalPath = "$parentPath/$_$finalSlash"
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            "'$finalPath'"
            "$_"
            'ParameterValue'
            "$finalPath"
        )
    }
}
