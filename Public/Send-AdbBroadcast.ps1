function Send-AdbBroadcast {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UserId')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent,

        [Parameter(ParameterSetName = 'UserId')]
        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [Parameter(ParameterSetName = 'AllUsers')]
        [switch] $AllUsers,

        [Parameter(ParameterSetName = 'CurrentUser')]
        [switch] $CurrentUser
    )

    begin {
        $intentArgs = $Intent.ToAdbArguments()

        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
        elseif ($AllUsers) {
            $userArg = " --user all"
        }
        elseif ($CurrentUser) {
            $userArg = " --user current"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell am broadcast$userArg $intentArgs" -Verbose:$VerbosePreference `
            | Out-String

            $broadcastingIntentLine = $rawResult -split '\r?\n' | Select-Object -First 1
            $actualHexFlags = $broadcastingIntentLine | Select-String -Pattern "Broadcasting: Intent \{ act=.* flg=(0x.+) cmp=.* \}" -AllMatches `
            | Select-Object -ExpandProperty Matches -First 1 `
            | ForEach-Object { $_.Groups[1].Value }
            $broacastCompletedMatch = $rawResult `
            | Select-String -Pattern "Broadcast completed: result=(?<result>\d+)(?:, data=""(?<data>[\s\S\n\r.]*?)"")?" -AllMatches `
            | Select-Object -ExpandProperty Matches -First 1

            $groups = $broacastCompletedMatch.Groups
            $broadCastResult = [int] $groups['result'].Value
            $broadcastData = $groups['data'].Value

            $broadcastOuput = [PSCustomObject]@{
                DeviceId = $id
                Result   = $broadCastResult
                Data     = $broadcastData
            }

            if ($actualHexFlags) {
                $actualIntFlags = [int] $actualHexFlags
                $broadcastOuput | Add-Member -MemberType NoteProperty -Name ActualFlags -Value $actualIntFlags
                $broadcastOuput | Add-Member -MemberType ScriptProperty -Name ActualHexFlags -Value {
                    "0x$($this.ActualFlags.ToString('x8'))"
                }
                $broadcastOuput | Add-Member -MemberType ScriptProperty -Name ActualFlagsArray -Value {
                    $flags = $this.ActualFlags
                    0..31 | ForEach-Object {
                        $bit = 1 -shl $_
                        if ($flags -band $bit) {
                            $bit
                        }
                    }
                }
                $broadcastOuput | Add-Member -MemberType ScriptProperty -Name ActualHexFlagsArray -Value {
                    $flags = $this.ActualFlags
                    0..31 | ForEach-Object {
                        $bit = 1 -shl $_
                        if ($flags -band $bit) {
                            "0x$($bit.ToString('x8'))"
                        }
                    }
                }
            }

            $broadcastOuput
        }
    }
}

# TODO: add support for the following parameters:
# --receiver-permission
# --allow-background-activity-starts
