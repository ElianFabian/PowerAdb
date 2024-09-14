function Get-AdbSystemTimeZone {

    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Get-AdbProperty -Name 'persist.sys.timezone'
    }
}
