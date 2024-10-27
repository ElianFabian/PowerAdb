function Test-AdbAppIsTestOnly {
    
    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        Test-AdbAppHasFlag -DeviceId $DeviceId -ApplicationId $ApplicationId -Flag "TEST_ONLY"
    }
}
