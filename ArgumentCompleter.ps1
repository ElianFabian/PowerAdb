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

    $WarningPreference = 'Ignore'

    Get-AdbDevice -Verbose:$false | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        $deviceName = Get-AdbDeviceName -DeviceId $_ -Verbose:$false -ErrorAction Ignore
        if (-not $deviceName) {
            $deviceName = 'unknown'
        }
        $apiLevel = Get-AdbApiLevel -DeviceId $_ -Verbose:$false -ErrorAction Ignore
        if (-not $apiLevel) {
            $apiLevel = 'unknown'
        }

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

    $WarningPreference = 'Ignore'

    $packageNames = Get-AdbPackage -DeviceId $deviceId -Verbose:$false

    $startMatches = $packageNames | Where-Object { $_ -like "$wordToComplete*" }
    $containMatches = $packageNames | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" }

    @($startMatches) + @($containMatches)
}

$packageFunctions = @(
    'Start-AdbPackage'
    'Get-AdbPackagePid'
    'Grant-AdbPermission'
    'Revoke-AdbPermission'
    'Start-AdbPackageCrash'
    'Stop-AdbPackage'
    'Start-AdbPackageProcessDeath'
    'Install-AdbPackage'
    'Uninstall-AdbPackage'
    'Clear-AdbPackage'
    'Stop-AdbService'
    'Get-AdbPackagePid'
    'Get-AdbPackageInfo'
    'Enable-AdbComponent'
    'Disable-AdbComponent'
    'Test-AdbPackageEnabled'
    'Get-AdbPackageApkPath'
    'Suspend-AdbPackage'
    'Resume-AdbPackage'
    'Test-AdbPackageSuspended'
    'Enable-AdbPackageLogVisibility'
    'Disable-AdbPackageLogVisibility'
)
AssertFunctionExists $packageFunctions

Register-ArgumentCompleter -CommandName $packageFunctions -ParameterName PackageName -ScriptBlock $packageCompletion


$runAsFunctions = @(
    'Test-AdbPath'
    'Get-AdbContent'
    'Get-AdbChildItem'
)
AssertFunctionExists $runAsFunctions

Register-ArgumentCompleter -CommandName $runAsFunctions -ParameterName RunAs -ScriptBlock $packageCompletion


$propertyFunctions = @(
    'Get-AdbProperty'
    'Set-AdbProperty'
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

    $WarningPreference = 'Ignore'

    $deviceProperties = Get-AdbProperty -DeviceId $deviceId -List -Verbose:$false | Select-Object -ExpandProperty Name

    $startMatches = $deviceProperties | Where-Object { $_ -like "$wordToComplete*" }
    $containMatches = $deviceProperties | Where-Object { $_ -like "*$wordToComplete*" -and $_ -notlike "$wordToComplete*" }

    @($startMatches; $containMatches) | Select-Object -Unique
}


$settingFunctions = @(
    'Get-AdbSetting'
    'Set-AdbSetting'
    'Remove-AdbSetting'
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

    # There doesn't seem to be a way to get the default value of a parameter
    if (-not $type) {
        $type = 'Default'
    }

    $WarningPreference = 'Ignore'

    $keys = [string[]] (Get-AdbSetting -DeviceId $deviceId -Namespace $namespace -List -Verbose:$false | Select-Object -ExpandProperty Key)
    $startMatches = [string[]] ($keys | Where-Object { $_ -like "$wordToComplete*" })
    $containMatches = [string[]] ($keys | Where-Object { $_ -like "*$wordToComplete*" })

    @($startMatches; $containMatches) | Select-Object -Unique
}



$script:AdbKeyCodes = @(
    'UNKNOWN'
    'MENU'
    'SOFT_RIGHT'
    'HOME'
    'BACK'
    'CALL'
    'ENDCALL'
    '0'
    '1'
    '2'
    '3'
    '4'
    '5'
    '6'
    '7'
    '8'
    '9'
    'STAR'
    'POUND'
    'DPAD_UP'
    'DPAD_DOWN'
    'DPAD_LEFT'
    'DPAD_RIGHT'
    'DPAD_CENTER'
    'VOLUME_UP'
    'VOLUME_DOWN'
    'POWER'
    'CAMERA'
    'CLEAR'
    'A'
    'B'
    'C'
    'D'
    'E'
    'F'
    'G'
    'H'
    'I'
    'J'
    'K'
    'L'
    'M'
    'N'
    'O'
    'P'
    'Q'
    'R'
    'S'
    'T'
    'U'
    'V'
    'W'
    'X'
    'Y'
    'Z'
    'COMMA'
    'PERIOD'
    'ALT_LEFT'
    'ALT_RIGHT'
    'CTRL_LEFT'
    'CTRL_RIGHT'
    'SHIFT_LEFT'
    'SHIFT_RIGHT'
    'TAB'
    'SPACE'
    'SYM'
    'EXPLORER'
    'ENVELOPE'
    'ENTER'
    'DEL'
    'GRAVE'
    'MINUS'
    'EQUALS'
    'LEFT_BRACKET'
    'RIGHT_BRACKET'
    'BACKSLASH'
    'SEMICOLON'
    'APOSTROPHE'
    'SLASH'
    'AT'
    'NUM'
    'HEADSETHOOK'
    'FOCUS'
    'PLUS'
    'MENU'
    'NOTIFICATION'
    'SEARCH'
    'ESCAPE'
    'BUTTON_START'
    'TAG_LAST_KEYCODE'
    'PAGE_UP'
    'PAGE_DOWN'
    'PASTE'
    'MOVE_HOME'
    'MOVE_END'
    'MEDIA_PLAY_PAUSE'
    'MEDIA_STOP'
    'MEDIA_NEXT'
    'MEDIA_PREVIOUS'
    'MEDIA_REWIND'
    'MEDIA_FAST_FORWARD'
    'MUTE'
    'PICTSYMBOLS'
)


$keyCodeFunction = @(
    'Send-AdbKeyEvent'
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
    'Send-AdbKeyCombination'
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

# WARNING: Be careful when modifying this autocompletion code since it's very easy to make it not work
# but just adding a few more lines of code.
$remotePathCompletion = {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    if ($fakeBoundParameters['RunAs']) {
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
    if (-not $hasFinalSlash) {
        $childPath = (Split-Path -Path $normalizedWordToComplete -Leaf -Verbose:$false).Replace('\', '/').Trim('/')
    }

    $WarningPreference = 'Ignore'

    $firstSlash = if ($runAs) { '' } else { '/' }

    # This is to make autocompletion work at the root level.
    # For some reason when putting empty single quotes the autocompletion does not work.
    if ($parentPath -eq '') {
        $quotedParentPath = ''
    }
    else {
        $quotedParentPath = "'$parentPath'"
    }

    # There's no good way to know if a symbolic link is a directory or a file that has no performance issues.
    # So, we aren't able to add a slash to the end of the directory, which would be a nice feature.
    # If you think the code looks weird or it's duplicated it's because we needed it to do it
    # in order to make the autocompletion work propertly, it can't stop working by just adding a few lines
    # of code or some simple small changes.
    if ($fakeBoundParameters['DeviceId']) {
        adb -s $fakeBoundParameters['DeviceId'] shell$runAsCommand "ls $quotedParentPath" 2> $null `
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
    else {
        adb shell$runAsCommand "ls $quotedParentPath" 2> $null `
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
}


$literalRemotePathFunctions = @(
    'Receive-AdbItem'
    'Send-AdbItem'
    'New-AdbItem'
    'Test-AdbPath'
    'Remove-AdbItem'
    'Move-AdbItem'
    'Invoke-AdbItem'
)
AssertFunctionExists $literalRemotePathFunctions

Register-ArgumentCompleter -CommandName $literalRemotePathFunctions -ParameterName LiteralRemotePath -ScriptBlock $remotePathCompletion


$remotePathFunctions = @(
    'Get-AdbContent'
    'Get-AdbChildItem'
    'Set-AdbContent'
    'Add-AdbContent'
    'Copy-AdbItem'
    'Move-AdbItem'
)
AssertFunctionExists $remotePathFunctions

Register-ArgumentCompleter -CommandName $remotePathFunctions -ParameterName RemotePath -ScriptBlock $remotePathCompletion


$remoteDestinationFunctions = @(
    'Copy-AdbItem'
    'Move-AdbItem'
)
AssertFunctionExists $remoteDestinationFunctions

Register-ArgumentCompleter -CommandName $remoteDestinationFunctions -ParameterName RemoteDestination -ScriptBlock $remotePathCompletion


$literalRemoteProfilerPathFunctions = @(
    'Start-AdbActivity'
)
AssertFunctionExists $literalRemoteProfilerPathFunctions

Register-ArgumentCompleter -CommandName $literalRemoteProfilerPathFunctions -ParameterName LiteralRemoteProfilerPath -ScriptBlock $remotePathCompletion



$userIdCompletion = {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    $WarningPreference = 'Ignore'

    if ($parameterName -eq 'UserId') {
        Write-Output 'current'
    }

    Get-AdbUser -DeviceId $deviceId -Verbose:$false | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            $_.Id
            "$($_.Id) ($($_.Name))"
            'ParameterValue'
            "$($_.Id) ($($_.Name))"
        )
    }
}

$userIdFunctions = @(
    'Remove-AdbUser'
    'Switch-AdbUser'
)
AssertFunctionExists $userIdFunctions

Register-ArgumentCompleter -CommandName $userIdFunctions -ParameterName Id -ScriptBlock $userIdCompletion



$longUserIdParamFunctions = @(
    'Get-AdbPackage'
    'Enable-AdbComponent'
    'Disable-AdbComponent'
    'Get-AdbContentEntry'
    'Get-AdbContentEntryType'
    'Remove-AdbContentEntry'
    'Set-AdbContentEntry'
    'Add-AdbContentEntry'
    'Resolve-AdbActivity'
    'Find-AdbActivity'
    'Find-AdbService'
    'Find-AdbBroadcastReceiver'
    'Get-AdbPackageInfo'
    'Suspend-AdbPackage'
    'Resume-AdbPackage'
    'Get-AdbPackageApkPath'
    'Start-AdbActivity'
    'Start-AdbService'
    'Start-AdbForegroundService'
    'Stop-AdbService'
)

Register-ArgumentCompleter -CommandName $longUserIdParamFunctions -ParameterName UserId -ScriptBlock $userIdCompletion



$permissionFunctions = @(
    'Grant-AdbPermission'
    'Revoke-AdbPermission'
    'Send-AdbBroadcast'
)

AssertFunctionExists $permissionFunctions

Register-ArgumentCompleter -CommandName $permissionFunctions -ParameterName PermissionName -ScriptBlock {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    Get-AdbPermission -DeviceId $deviceId -Verbose:$false `
    | Where-Object { $_ -like "$wordToComplete*" } `
    | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            $_
            "$_"
            'ParameterValue'
            "$_"
        )
    }
}



$intentFunctions = @(
    'New-AdbIntent'
)

AssertFunctionExists $intentFunctions

Register-ArgumentCompleter -CommandName $intentFunctions -ParameterName NamedFlag -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $values = Get-IntentNamedFlag -ApiLevel ([int]::MaxValue)

    $startMatches = [string[]] ($values | Where-Object { $_ -like "$wordToComplete*" })
    $containMatches = [string[]] ($values | Where-Object { $_ -like "*$wordToComplete*" })

    @($startMatches; $containMatches) | Select-Object -Unique
}



$serviceNameFunctions = @(
    'Get-AdbServiceDump'
)
AssertFunctionExists $serviceNameFunctions

Register-ArgumentCompleter -CommandName $serviceNameFunctions -ParameterName Name -ScriptBlock {

    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $deviceId = $fakeBoundParameters['DeviceId']

    $values = Get-AdbRunningService -DeviceId $deviceId

    $startMatches = [string[]] ($values | Where-Object { $_ -like "$wordToComplete*" })
    $containMatches = [string[]] ($values | Where-Object { $_ -like "*$wordToComplete*" })

    @($startMatches; $containMatches) | Select-Object -Unique
}
