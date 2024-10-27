function Test-AdbAppHasCode {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        Test-AdbAppHasFlag -DeviceId $DeviceId -ApplicationId $ApplicationId -Flag "HAS_CODE"
    }
}
