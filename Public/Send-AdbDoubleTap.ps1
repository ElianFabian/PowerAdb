
function Send-AdbDoubleTap {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node,

        [switch] $DisableCoordinateCheck
    )

    process {
        foreach ($id in $DeviceId) {
            if (Test-AdbEmulator -DeviceId $id) {
                $boundParametersCopy = [hashtable] $PSBoundParameters
                $boundParametersCopy['DeviceId'] = $id

                Send-AdbTap @boundParametersCopy
                Send-AdbTap @boundParametersCopy
                continue
            }

            # For real devices the implementation  is not straightforward
            # since there's 1 second delay between taps.
            # Probably the implemention could be improved, but at least
            # it seems to work reliably on real devices.
            # But it's pretty slow.

            $timestamps = [System.Collections.Generic.List[PSCustomObject]]::new()
            $break = [System.Collections.Generic.List[int]]::new()

            1..3 | ForEach-Object {
                $boundParametersCopy = [hashtable] $PSBoundParameters
                $boundParametersCopy['DeviceId'] = $id
                $jobName = New-PowerAdbJobName -Tag "SendAdbDoubleTap.$id.$_"

                $job = ForEach-Object {
                    # It seems that in other to work we have to execute the code
                    # in a separate process, a thread doesn't work.
                    Start-Job -Name $jobName -ScriptBlock {
                        param ($boundParametersCopy, $scriptRoot)
                        $verbose = $boundParametersCopy['Verbose']
                        $VerbosePreference = 'SilentlyContinue'
                        Import-Module -Name "$scriptRoot/../PowerAdb.psm1" -Force -Verbose:$false
                        $VerbosePreference = $verbose

                        Send-AdbTap @boundParametersCopy
                    } -ArgumentList $boundParametersCopy, $PSScriptRoot
                }

                Register-ObjectEvent -InputObject $job -EventName 'StateChanged' -MessageData @{ timestamps = $timestamps; break = $break } -Action {
                    $timestamps = $Event.MessageData.timestamps
                    $break = $Event.MessageData.break
                    if ($break.Count -gt 0) {
                        Remove-Job -Id $Sender.Id -Force
                        Remove-Job -Name $Event.SourceIdentifier -Force
                        Unregister-Event -SubscriptionId $Event.EventIdentifier
                        $timestamps.Clear()
                        return
                    }
                    if ($Sender.State -eq "Completed") {
                        # Show any output from the job
                        Receive-Job $Sender.id

                        $selfTimestamp = [System.DateTimeOffset]::Now.ToUnixTimeMilliseconds()
                        $timestamps.Add([PSCustomObject]@{JobId = $Sender.Id; Timestamp = $selfTimestamp })

                        if ($timestamps.Count -ge 2) {
                            $first = $timestamps[0]
                            $second = $timestamps[1]

                            $diff = [math]::Abs($first.Timestamp - $second.Timestamp)
                            if ($diff -lt 300) {
                                $break.Add($first.JobId)
                                Remove-Job -Id $Sender.Id -Force
                                Remove-Job -Name $Event.SourceIdentifier -Force
                                Unregister-Event -SubscriptionId $Event.EventIdentifier
                                $timestamps.Clear()
                                return
                            }

                            $timestamps.RemoveAt(0)
                        }

                        Remove-Job -Id $Sender.Id -Force
                        Remove-Job -Name $Event.SourceIdentifier -Force
                        Unregister-Event -SubscriptionId $Event.EventIdentifier
                    }
                    elseif ($Sender.State -eq "Failed" -or $Sender.State -eq "Stopped" -or $Sender.State -eq "Stopping") {
                        Remove-Job -Id $Sender.Id -Force
                        Remove-Job -Name $Event.SourceIdentifier -Force
                        Unregister-Event -SubscriptionId $Event.EventIdentifier
                    }
                } | Out-Null
            }

            while ($break.Count -eq 0) { }
        }
    }
}
