function Set-CacheValue {

    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [string] $FunctionName =  (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [string] $Key,

        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value
    )

    if (-not $PowerAdbCache) {
        return
    }

    $serial = $SerialNumber
    if (-not $serial) {
        $serial = Get-AdbDevice -Verbose:$false
    }

    $cacheKey = "$serial`:$FunctionName"
    if ($Key) {
        $cacheKey = "$cacheKey`:$Key"
    }

    if (-not $PowerAdbCache.ContainsKey($cacheKey)) {
        $PowerAdbCache[$cacheKey] = $Value

        $jobName = New-PowerAdbJobName -Tag "RemoveCacheFor.$serial"
        $job = Get-Job -Name $jobName -ErrorAction Ignore
        if ($job -and $job.State -eq 'Running') {
            return
        }

        $removeCachedValuesJob = Start-ThreadJob -Name $jobName -ScriptBlock {
            $serial, $PowerAdbCache, $scriptRoot = $args

            . "$scriptRoot/Remove-CacheValue.ps1"

            & 'adb' '-s' "$serial" 'wait-for-any-disconnect'
            Remove-CacheValue -SerialNumber $serial -All
        } -ArgumentList $serial, $PowerAdbCache, $PSScriptRoot

        # Cleanup the job automatically after completion
        Register-ObjectEvent -InputObject $removeCachedValuesJob -EventName 'StateChanged' -Action {
            if ($Sender.State -eq 'Running') {
                return
            }
            if ($Sender.State -eq 'Completed') {
                Remove-Job $Sender.Id
            }
            else {
                # Just for debugging
                # Write-Warning -Message "Job $($Sender.Name) completed with an unexpected status: $($Sender.State)."
            }

            Remove-Job -Name $Event.SourceIdentifier -Force
            Unregister-Event -SubscriptionId $Event.EventIdentifier
        } | Out-Null
    }
    else {
        Write-Error "Value for key '$Key' for device with serial number '$serial' is already cached with value '$cachedValue'"
    }
}
