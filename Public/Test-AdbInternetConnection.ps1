function Test-AdbInternetConnection {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $result = Invoke-AdbExpression -DeviceId $id -Command 'shell ping -c1 www.google.com' -Verbose:$VerbosePreference 2>&1

            $result -and ($result -isnot [System.Management.Automation.ErrorRecord])
        }
    }
}
