param (
    [System.IO.FileInfo[]] $PublicFunctionFileName
)

$functionNames = $PublicFunctionFileName | Select-Object -ExpandProperty BaseName

function AssertFunctionExists {

    param (
        [string[]] $FunctionName
    )

    foreach ($functionName in $FunctionName) {
        if ($functionName -notin $functionNames) {
            Write-Error "Trying to add an argument completer for a non-existent function: $functionName"
        }
    }
}


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

    $packageNames = Get-AdbPackage -DeviceId $deviceId -Verbose:$false

    $startMatches = $packageNames | Where-Object { $_ -like "$wordToComplete*" }
    $containMatches = $packageNames | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" }

    @($startMatches) + @($containMatches)
}

$packageFunctions = @(
    "Start-AdbPackage"
    "Get-AdbPackagePid"
    "Grant-AdbPermission"
    "Revoke-AdbPermission"
    "Start-AdbPackageCrash"
    "Stop-AdbPackage"
    "Start-AdbPackageProcessDeath"
    "Install-AdbPackage"
    "Uninstall-AdbPackage"
    "Clear-AdbPackageData"
    "Stop-AdbService"
    "Get-AdbPackagePid"
)
AssertFunctionExists $packageFunctions

Register-ArgumentCompleter -CommandName $packageFunctions -ParameterName PackageName -ScriptBlock $packageCompletion


$runAsFunctions = @(
    "Test-AdbPath"
    "Get-AdbContent"
    "Get-AdbChildItem"
)
AssertFunctionExists $runAsFunctions

Register-ArgumentCompleter -CommandName $runAsFunctions -ParameterName RunAs -ScriptBlock $packageCompletion


$propertyFunctions = @(
    "Get-AdbProperty"
    "Set-AdbProperty"
)
AssertFunctionExists $propertyFunctions

Register-ArgumentCompleter -CommandName $propertyFunctions -ParameterName Name -ScriptBlock {

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


$settingFunctions = @(
    "Get-AdbSetting"
    "Set-AdbSetting"
    "Remove-AdbSetting"
)
AssertFunctionExists $settingFunctions

Register-ArgumentCompleter -CommandName $settingFunctions -ParameterName Key -ScriptBlock {

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
    $containMatches = [string[]] ($keys | Where-Object { $_ -like "*$wordToComplete*" })

    @($startMatches; $containMatches) | Select-Object -Unique
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


$keyCodeFunction = @(
    "Send-AdbKeyEvent"
)
AssertFunctionExists $keyCodeFunction

Register-ArgumentCompleter -CommandName $keyCodeFunction -ParameterName KeyCode -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $script:AdbKeyCodes | Where-Object { $_ -like "$wordToComplete*" }
}


$keyCodesFunction = @(
    "Send-AdbKeyCombination"
)
AssertFunctionExists $keyCodesFunction

Register-ArgumentCompleter -CommandName $keyCodesFunction -ParameterName KeyCodes -ScriptBlock {

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


$literalRemotePathFunctions = @(
    "Receive-AdbItem"
    "Send-AdbItem"
    "New-AdbItem"
    "Test-AdbPath"
    "Remove-AdbItem"
    "Move-AdbItem"
)
AssertFunctionExists $literalRemotePathFunctions

Register-ArgumentCompleter -CommandName $literalRemotePathFunctions -ParameterName LiteralRemotePath -ScriptBlock $remotePathCompletion


$remotePathFunctions = @(
    "Get-AdbContent"
    "Get-AdbChildItem"
    "Set-AdbContent"
    "Add-AdbContent"
    "Copy-AdbItem"
    "Move-AdbItem"
    "Start-AdbActivity"
)
AssertFunctionExists $remotePathFunctions

Register-ArgumentCompleter -CommandName $remotePathFunctions -ParameterName RemotePath -ScriptBlock $remotePathCompletion


$remoteDestinationFunctions = @(
    "Copy-AdbItem"
    "Move-AdbItem"
)
AssertFunctionExists $remoteDestinationFunctions

Register-ArgumentCompleter -CommandName $remoteDestinationFunctions -ParameterName RemoteDestination -ScriptBlock $remotePathCompletion


$literalRemoteProfilerPathFunctions = @(
    "Start-AdbActivity"
)
AssertFunctionExists $literalRemoteProfilerPathFunctions

Register-ArgumentCompleter -CommandName $literalRemoteProfilerPathFunctions -ParameterName LiteralRemoteProfilerPath -ScriptBlock $remotePathCompletion
