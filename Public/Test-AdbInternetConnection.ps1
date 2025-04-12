function Test-AdbInternetConnection {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    try {
        $result = Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell ping -c1 www.google.com' -Verbose:$VerbosePreference

        if ($result) {
            return $true
        }
        else {
            return $false
        }
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.Contains('ping: unknown host www.google.com')) {
            return $false
        }
        throw $_
    }
}
