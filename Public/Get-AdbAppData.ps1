function Get-AdbAppData {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId,

        [switch] $AllData,

        [switch] $VersionCode,

        [switch] $VersionName,

        [switch] $MinSdkVersion,

        [switch] $TargetSdkVersion,

        [switch] $FirstInstallDate,

        [switch] $LastUpdateDate,

        [switch] $Sha256Signature,

        [switch] $AllowClearUserData,

        [switch] $Debuggable,

        [switch] $LargeHeap,

        [switch] $AllowBackup,

        [switch] $KillAfterRestore,

        [switch] $TestOnly,

        [switch] $HasCode
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                # For more information: https://developer.android.com/guide/topics/manifest/application-element
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false

                if ($AllData -or $VersionCode) {
                    $versionCodeValue = $rawData `
                    | Select-String -Pattern "versionCode=(\d+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [uint32] $_.Groups[1].Value }
                }
                if ($AllData -or $VersionName) {
                    $versionNameValue = $rawData `
                    | Select-String -Pattern "versionName=(\S+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Groups[1].Value }
                }
                if ($AllData -or $MinSdkVersion) {
                    $minSdkVersionValue = $rawData `
                    | Select-String -Pattern "minSdk=(\d+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [uint32] $_.Groups[1].Value }
                }
                if ($AllData -or $TargetSdkVersion) {
                    $targetSdkVersionValue = $rawData `
                    | Select-String -Pattern "targetSdk=(\d+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [uint32] $_.Groups[1].Value }
                }
                if ($AllData -or $FirstInstallDate) {
                    $firstInstallDateValue = $rawData `
                    | Select-String -Pattern "firstInstallTime=(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { Get-Date -Date $_.Groups[1].Value }
                }
                if ($AllData -or $LastUpdateDate) {
                    $lastUpdateDateValue = $rawData `
                    | Select-String -Pattern "lastUpdateTime=(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { Get-Date -Date $_.Groups[1].Value }
                }
                if ($AllData -or $Sha256Signature) {
                    $sha256SignatureValue = $rawData `
                    | Select-String -Pattern "Signatures: \[(.+)\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Groups[1].Value }
                }
                if ($AllData -or $AllowClearUserData) {
                    $allowClearUserDataValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("ALLOW_CLEAR_USER_DATA") }
                }
                if ($AllData -or $Debuggable) {
                    $debuggableValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("DEBUGGABLE") }
                }
                if ($AllData -or $LargeHeap) {
                    $largeHeapValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("LARGE_HEAP") }
                }
                if ($AllData -or $AllowBackup) {
                    $allowBackupValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("ALLOW_BACKUP") }
                }
                if ($AllData -or $KillAfterRestore) {
                    $killAfterRestoreValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("KILL_AFTER_RESTORE") }
                }
                if ($AllData -or $TestOnly) {
                    $testOnlyValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("TEST_ONLY") }
                }
                if ($AllData -or $HasCode) {
                    $hasCodeValue = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value.Contains("HAS_CODE") }
                }
                
                [PSCustomObject]@{
                    DeviceId           = $id
                    ApplicationId      = $appId
                    VersionCode        = $versionCodeValue
                    VersionName        = $versionNameValue
                    MinSdkVersion      = $minSdkVersionValue
                    TargetSdkVersion   = $targetSdkVersionValue
                    FirstInstallDate   = $firstInstallDateValue
                    LastUpdateDate     = $lastUpdateDateValue
                    Sha256Signature    = $sha256SignatureValue
                    AllowClearUserData = $allowClearUserDataValue
                    Debuggable         = $debuggableValue
                    LargeHeap          = $largeHeapValue
                    AllowBackup        = $allowBackupValue
                    KillAfterRestore   = $killAfterRestoreValue
                    TestOnly           = $testOnlyValue
                    HasCode            = $hasCodeValue
                }
            }
        }
    }
}
