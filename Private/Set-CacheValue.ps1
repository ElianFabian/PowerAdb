function Set-CacheValue {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId,

        [string] $FunctionName =  (Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command),

        [string] $Key,

        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value
    )

    $cacheKey = "$DeviceId`:$FunctionName"
    if ($Key) {
        $cacheKey = "$cacheKey`:$Key"
    }

    if (-not $PowerAdbCache.ContainsKey($cacheKey)) {
        $PowerAdbCache[$cacheKey] = $Value

        $jobName = New-PowerAdbJobName -Tag "RemoveCacheFor.$DeviceId"
        $job = Get-Job -Name $jobName -ErrorAction SilentlyContinue
        if ($job -and $job.State -eq 'Running') {
            return
        }

        $removeCachedValuesJob = Start-ThreadJob -Name $jobName -ScriptBlock {
            $id, $PowerAdbCache, $scriptRoot = $args

            . "$scriptRoot/Remove-CacheValue.ps1"

            & 'adb' '-s' "$id" 'wait-for-any-disconnect'
            Remove-CacheValue -DeviceId $id -All
        } -ArgumentList $DeviceId, $PowerAdbCache, $PSScriptRoot

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
