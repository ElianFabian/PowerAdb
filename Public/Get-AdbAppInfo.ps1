function Get-AdbAppInfo {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId,

        [switch] $AllInfo,

        [switch] $VersionCode,

        [switch] $VersionName,

        [switch] $MinSdkVersion,

        [switch] $TargetSdkVersion,

        [switch] $FirstInstallDate,

        [switch] $LastUpdateDate,

        [switch] $Sha256Signature,

        [switch] $ForceQueryable,

        [switch] $InstallerPackageName,

        [switch] $PackageFlags,

        [switch] $PrivatePackageFlags
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                # For more information: https://developer.android.com/guide/topics/manifest/application-element
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false

                if ($AllInfo -or $VersionCode) {
                    $versionCodeValue = $rawData `
                    | Select-String -Pattern "versionCode=(\d+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [uint32] $_.Groups[1].Value }
                }
                if ($AllInfo -or $VersionName) {
                    $versionNameValue = $rawData `
                    | Select-String -Pattern "versionName=(\S+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Groups[1].Value }
                }
                if ($AllInfo -or $MinSdkVersion) {
                    $minSdkVersionValue = $rawData `
                    | Select-String -Pattern "minSdk=(\d+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [uint32] $_.Groups[1].Value }
                }
                if ($AllInfo -or $TargetSdkVersion) {
                    $targetSdkVersionValue = $rawData `
                    | Select-String -Pattern "targetSdk=(\d+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [uint32] $_.Groups[1].Value }
                }
                if ($AllInfo -or $FirstInstallDate) {
                    $firstInstallDateValue = $rawData `
                    | Select-String -Pattern "firstInstallTime=(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { Get-Date -Date $_.Groups[1].Value }
                }
                if ($AllInfo -or $LastUpdateDate) {
                    $lastUpdateDateValue = $rawData `
                    | Select-String -Pattern "lastUpdateTime=(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { Get-Date -Date $_.Groups[1].Value }
                }
                if ($AllInfo -or $Sha256Signature) {
                    $sha256SignatureValue = $rawData `
                    | Select-String -Pattern "Signatures: \[(.+)\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Groups[1].Value }
                }
                if ($AllInfo -or $ForceQueryable) {
                    $forceQueryableValue = $rawData `
                    | Select-String -Pattern "forceQueryable=(true|false)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { [bool]::Parse($_.Groups[1].Value) }
                }
                if ($AllInfo -or $InstallerPackageName) {
                    $installerPackageNameValue = $rawData `
                    | Select-String -Pattern "installerPackageName=(.+)" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Groups[1].Value }
                }
                if ($AllInfo -or $PackageFlags) {
                    $rawFlags = $rawData `
                    | Select-String -Pattern "flags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value }

                    if ($rawFlags) {
                        $packageFlagsValue = [PSCustomObject]@{
                            AllowBackup          = $rawFlags.Contains("ALLOW_BACKUP")
                            AllowClearUserData   = $rawFlags.Contains("ALLOW_CLEAR_USER_DATA")
                            AllowTaskReparenting = $rawFlags.Contains("ALLOW_TASK_REPARENTING")
                            Debuggable           = $rawFlags.Contains("DEBUGGABLE")
                            DirectBootAware      = $rawFlags.Contains("PARTIALLY_DIRECT_BOOT_AWARE")
                            HasCode              = $rawFlags.Contains("HAS_CODE")
                            LargeHeap            = $rawFlags.Contains("LARGE_HEAP")
                            KillAfterRestore     = $rawFlags.Contains("KILL_AFTER_RESTORE")
                            TestOnly             = $rawFlags.Contains("TEST_ONLY")
                            VmSafeMode           = $rawFlags.Contains("VM_SAFE_MODE")
                        }
                    }
                }
                if ($AllInfo -or $PrivatePackageFlags) {
                    $privateRawFlags = $rawData `
                    | Select-String -Pattern "privateFlags=\[\s.+\s\]" `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Value }

                    if ($privateRawFlags) {
                        $privatePackageFlagsValue = [PSCustomObject]@{
                            AllowAudioPlaybackCapture     = $privateRawFlags.Contains("ALLOW_AUDIO_PLAYBACK_CAPTURE")
                            AllowNativeHeapPointerTagging = $privateRawFlags.Contains("PRIVATE_FLAG_ALLOW_NATIVE_HEAP_POINTER_TAGGING")
                            # The opposite flag for ResizableActivity is "PRIVATE_FLAG_ACTIVITIES_RESIZE_MODE_UNRESIZEABLE"
                            ResizableActivity             = $privateRawFlags.Contains("PRIVATE_FLAG_ACTIVITIES_RESIZE_MODE_RESIZEABLE")
                        }
                    }
                }

                [PSCustomObject]@{
                    DeviceId             = $id
                    ApplicationId        = $appId
                    VersionCode          = $versionCodeValue
                    VersionName          = $versionNameValue
                    MinSdkVersion        = $minSdkVersionValue
                    TargetSdkVersion     = $targetSdkVersionValue
                    FirstInstallDate     = $firstInstallDateValue
                    LastUpdateDate       = $lastUpdateDateValue
                    Sha256Signature      = $sha256SignatureValue
                    ForceQueryable       = $forceQueryableValue
                    InstallerPackageName = $installerPackageNameValue
                    PackageFlags         = $packageFlagsValue
                    PrivatePackageFlags  = $privatePackageFlagsValue
                }
            }
        }
    }
}
