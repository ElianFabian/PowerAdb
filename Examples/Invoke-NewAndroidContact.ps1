function Invoke-NewAndroidContact {

    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [string] $Name,

        [string] $Phone,

        [string] $Email,

        [string] $Company,

        [string] $JobTitle,

        [string] $Notes
    )

    $intent = New-AdbIntent `
        -Action 'android.intent.action.INSERT' `
        -Type 'vnd.android.cursor.dir/contact' `
        -Extras {
        New-AdbBundlePair -Key 'name' -String $Name
        New-AdbBundlePair -Key 'phone' -String $Phone
        New-AdbBundlePair -Key 'email' -String $Email
        New-AdbBundlePair -Key 'company' -String $Company
        New-AdbBundlePair -Key 'job_title' -String $JobTitle
        New-AdbBundlePair -Key 'notes' -String $Notes
    }

    Start-AdbActivity -DeviceId $DeviceId -Intent $intent
}
