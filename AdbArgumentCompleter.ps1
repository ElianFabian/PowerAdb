Register-ArgumentCompleter `
    -CommandName (Get-Command -Name (Get-ChildItem -LiteralPath "$PSScriptRoot/Public/" -File | Select-Object -ExpandProperty BaseName)) `
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

    $deviceId | Get-AdbSetting -Namespace $namespace -List
    | ForEach-Object { $_.Key }
    | Where-Object { $_ -like "*$wordToComplete*" }
    | ForEach-Object { "$_" }
}
