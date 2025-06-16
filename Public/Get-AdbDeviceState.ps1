function Get-AdbDeviceState {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $DeviceId
    )

    try {
        return Invoke-AdbExpression -DeviceId $DeviceId -Command "get-state" -IgnoreExecutionCheck -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message -eq 'error: device offline') {
            return 'offline'
        }
        throw $_
    }
}


### See Invoke-AdbExpression.ps1 for more information.
# function Get-AdbDeviceState {

#     [CmdletBinding(DefaultParameterSetName = 'Default')]
#     [OutputType([string])]
#     param(
#         [string] $DeviceId,

#         # When the device is offline the command blocks for some time and returns an error,
#         # with this we prevent that behavior and return 'offline'
#         [Parameter(ParameterSetName = 'PreventLock')]
#         [switch] $PreventLock,

#         [Parameter(ParameterSetName = 'PreventLock')]
#         [int] $Timeout = 1
#     )

#     $device = Resolve-AdbDevice -DeviceId $DeviceId -IgnoreExecutionCheck

#     if (-not $PreventLock) {

#         $result = adb -s "$device" get-state 2>&1

#         if ($result -is [System.Management.Automation.ErrorRecord] -and
#             $result.Exception.Message.Contains('error: device offline')
#         ) {
#             return 'offline'
#         }

#         return $result
#     }

#     $job = Start-ThreadJob {
#         param($device, $verbose)

#         Write-Verbose "adb -s $device get-state" -Verbose:$verbose
#         adb -s "$device" get-state 2>&1

#     } -ArgumentList $device, $VerbosePreference

#     if (Wait-Job -Job $job -Timeout $Timeout) {
#         $result = Receive-Job $job

#         if ($result -is [System.Management.Automation.ErrorRecord] -and
#             $result.Exception.Message.Contains('error: device offline')
#         ) {
#             return 'offline'
#         }

#         return $result
#     }
#     else {
#         Remove-Job $job -Force | Out-Null

#         return "offline"
#     }
# }
