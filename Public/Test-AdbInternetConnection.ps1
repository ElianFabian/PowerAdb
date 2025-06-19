function Test-AdbInternetConnection {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    try {
        $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell ping -c1 www.google.com' -Verbose:$VerbosePreference

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
