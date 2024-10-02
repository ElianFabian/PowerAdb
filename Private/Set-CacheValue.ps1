function Set-CacheValue {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [string] $Key =  (Get-PSCallStack | Select-Object -Skip 1 | Select-Object -First 1 -ExpandProperty Command),

        [Parameter(Mandatory)]
        [string] $Value
    )

    $cacheKey = "$DeviceId.$Key"

    $cachedValue = $AdbCache[$cacheKey]

    if ($null -eq $cachedValue) {
        $AdbCache[$cacheKey] = $Value

        $jobName = "PowerAdb.RemoveCacheFor:$DeviceId"

        $job = Get-Job -Name $jobName -ErrorAction SilentlyContinue
        if ($job -and $job.State -eq 'Running') {
            return
        }

        $removeCachedValuesJob = Start-ThreadJob -Name $jobName -ScriptBlock {
            $id, $AdbCache, $scriptRoot = $args

            . "$scriptRoot/Remove-CacheValue.ps1"

            & 'adb' '-s' "$id" 'wait-for-any-disconnect'
            Write-Host "Device with id '$id' disconnected. Removing cached values." -ForegroundColor Green
            Remove-CacheValue -DeviceId $id -All
            Write-Host "Removed cached values for device with id '$id'." -ForegroundColor Green
        } -ArgumentList $DeviceId, $AdbCache, $PSScriptRoot

        # Cleanup the job automatically after completion
        Register-ObjectEvent -InputObject $removeCachedValuesJob -EventName 'StateChanged' -Action {
            if ($Sender.State -eq 'Running') {
                return
            }
            if ($Sender.State -eq "Completed") {
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
        Write-Error "Value for key '$Key' for device with id '$DeviceId' is already cached with value '$cachedValue'"
    }
}
