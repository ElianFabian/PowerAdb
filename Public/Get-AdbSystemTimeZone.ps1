function Get-AdbSystemTimeZone {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Get-AdbProperty -Name 'persist.sys.timezone' -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
    }
}
