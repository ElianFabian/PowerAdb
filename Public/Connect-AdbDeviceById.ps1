function Connect-AdbDeviceById {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Start-AdbTcpIp -DeviceId $id -Port 5555 -Verbose:$VerbosePreference
            $ipAdress = Get-AdbLocalNetworkIp -DeviceId $id -Wait -Verbose:$VerbosePreference
            Connect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
        }
    }
}
