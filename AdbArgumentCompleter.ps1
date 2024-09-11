param (
    [string[]] $Path
)

$functionNames = Get-ChildItem -LiteralPath "$PSScriptRoot/Public/" -File `
| Where-Object { -not (.\Test-IncorrectFileFunction.ps1 -Path $_.FullName) } `
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

    Get-AdbDevice | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        $deviceName = Get-AdbDeviceName -DeviceId $_
        $apiLevel = Get-AdbProp -DeviceId $_ -PropertyName "ro.build.version.sdk"

        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            $_
            "$_ ($deviceName, $apiLevel)"
            'ParameterValue'
            "Device: $deviceName`nAPI level: $apiLevel"
        )
    }
}

Register-ArgumentCompleter -CommandName @(
    "Start-AdbApplication"
    "Get-AdbApplicationPid"
    "Grant-AdbPermission"
    "Revoke-AdbPermission"
    "Start-AdbCrash"
    "Invoke-AdbDeepLink"
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

    $applicationIds = Get-AdbPackage -DeviceId $deviceId

    $startMatches = $applicationIds | Where-Object { $_ -like "$wordToComplete*" }
    $containMatches = $applicationIds | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" }
    $startMatches + $containMatches
}

Register-ArgumentCompleter -CommandName @(
    "Get-AdbProp"
    "Set-AdbProp"
) -ParameterName PropertyName -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    $deviceProperties = Get-AdbProp -DeviceId $deviceId -List | Select-Object -ExpandProperty Property

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

    $keys = [string[]] (Get-AdbSetting -DeviceId $deviceId -Namespace $namespace -List | Select-Object -ExpandProperty Key)
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
