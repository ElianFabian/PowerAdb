function Test-AdbAppAllowClearUserData {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        Test-AdbAppHasFlag -DeviceId $DeviceId -ApplicationId $ApplicationId -Flag "ALLOW_CLEAR_USER_DATA"
    }
}
