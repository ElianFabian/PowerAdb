function Send-AdbBroadcast {

    [OutputType([PSCustomObject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent,

        [string] $PermissionName
    )

    Assert-ValidIntent -SerialNumber $SerialNumber -Intent $Intent

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false

    $intentArgs = $Intent.ToAdbArguments($SerialNumber)

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }
    if ($PermissionName -and $apiLevel -ge 18) {
        $permissionArg = " --receiver-permission $PermissionName"
    }

    $rawResult = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am broadcast$userArg$permissionArg$intentArgs" -Verbose:$VerbosePreference `
    | Out-String

    $broadcastingIntentLine = $rawResult -split '\r?\n' | Select-Object -First 1
    $actualHexFlags = $broadcastingIntentLine | Select-String -Pattern "Broadcasting: Intent \{ act=.* flg=(0x.+) cmp=.* \}" -AllMatches `
    | Select-Object -ExpandProperty Matches -First 1 `
    | ForEach-Object { $_.Groups[1].Value }
    $broacastCompletedMatch = $rawResult `  
    | Select-String -Pattern "Broadcast completed: result=(?<result>-?\d+)(?:, data=""(?<data>[\s\S\n\r.]*?)"")?" -AllMatches `
    | Select-Object -ExpandProperty Matches -First 1

    $groups = $broacastCompletedMatch.Groups
    $broadCastResult = [int] $groups['result'].Value
    $broadcastData = $groups['data'].Value

    $broadcastOuput = [PSCustomObject]@{
        Result = $broadCastResult
        Data   = $broadcastData
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

    return $broadcastOuput
}
