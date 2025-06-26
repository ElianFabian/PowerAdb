function Connect-AdbDevice {

    [OutputType([bool])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    try {
        $result = Invoke-AdbExpression -Command "connect ""$IpAddress`:$Port""" -IgnoreExecutionCheck -Verbose:$VerbosePreference
        if ($result.StartsWith('cannot resolve host') -or $result.StartsWith('cannot connect to')) {
            Write-Error $result -ErrorAction Stop
        }
        if ($result.StartsWith('failed to authenticate to')) {
            Write-Host $result -ForegroundColor Green
            return $false
        }

        Write-Verbose $result

        return $true
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.Contains('cannot connect to')) {
            Write-Error "Check that the device '$IpAddress`:$Port' is connected to the same network as your computer"
            throw $_
        }
    }
}
