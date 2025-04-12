# Based on: https://github.com/firebase/firebase-android-sdk/blob/main/firebase-crashlytics/src/main/java/com/google/firebase/crashlytics/internal/common/CommonUtils.java
function Test-AdbRoot {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    # No reliable way to determine if an android phone is rooted, since a rooted phone could
    # always disguise itself as non-rooted. Some common approaches can be found on SO:
    # - http://stackoverflow.com/questions/1101380/determine-if-running-on-a-rooted-device
    # - http://stackoverflow.com/questions/3576989/how-can-you-detect-if-the-device-is-rooted-in-the-app
    # - http://stackoverflow.com/questions/7727021/how-can-androids-copy-protection-check-if-the-device-is-rooted
    $buildTags = Get-AdbProperty -DeviceId $DeviceId -Name 'ro.build.tags' -Verbose:$false
    if ($buildTags -and $buildTags.Contains('test-keys')) {
        return $true
    }

    # Superuser.apk would only exist on a rooted device:
    if (Test-AdbPath -DeviceId $DeviceId -LiteralRemotePath 'system/app/Superuser.apk') {
        return $true
    }

    # su is only available on a rooted device
    # The user could rename or move to a non-standard location, but in that case they
    # probably don't want us to know they're root and they can pretty much subvert
    # any check anyway.
    if (Test-AdbPath -DeviceId $DeviceId -LiteralRemotePath 'system/xbin/su') {
        return $true
    }

    return $false
}
