function Get-AdbDeviceState {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string] $SerialNumber
    )

    try {
        return Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'get-state' -IgnoreExecutionCheck -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message -eq 'error: device offline') {
            Write-Verbose $_
            return 'offline'
        }
        if ($_.Exception.Message.StartsWith('error: device unauthorized')) {
            Write-Verbose $_
            return 'unauthorized'
        }
        throw $_
    }
}


### See Invoke-AdbExpression.ps1 for more information.
# function Get-AdbDeviceState {

#     [CmdletBinding(DefaultParameterSetName = 'Default')]
#     [OutputType([string])]
#     param(
#         [string] $SerialNumber,

#         # When the device is offline the command blocks for some time and returns an error,
#         # with this we prevent that behavior and return 'offline'
#         [Parameter(ParameterSetName = 'PreventLock')]
#         [switch] $PreventLock,

#         [Parameter(ParameterSetName = 'PreventLock')]
#         [int] $Timeout = 1
#     )

#     $serial = Resolve-AdbDevice -SerialNumber $SerialNumber -IgnoreExecutionCheck

#     if (-not $PreventLock) {

#         $result = adb -s "$serial" get-state 2>&1

#         if ($result -is [System.Management.Automation.ErrorRecord] -and
#             $result.Exception.Message.Contains('error: device offline')
#         ) {
#             return 'offline'
#         }

#         return $result
#     }

#     $job = Start-ThreadJob {
#         param($serial, $verbose)

#         Write-Verbose "adb -s $serial get-state" -Verbose:$verbose
#         adb -s "$serial" get-state 2>&1

#     } -ArgumentList $serial, $VerbosePreference

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
