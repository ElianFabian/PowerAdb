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

    $resultMatch = [regex]::Match($rawResult, 'result=(-?\d+)')
    $broadCastResult = if ($resultMatch.Success) { [int]$resultMatch.Groups[1].Value }

    $dataStart = $rawResult.IndexOf('data="')
    $broadcastData = $null
    $broadcastExtras = $null

    if ($dataStart -ge 0) {
        $broadcastData = $rawResult.Substring($dataStart + 'data="'.Length)

        $extrasIndex = $broadcastData.LastIndexOf('", extras:')
        if ($extrasIndex -ge 0) {
            $broadcastExtras = $broadcastData.Substring($extrasIndex + '", '.Length).Trim().TrimEnd("`r`n").Substring('extras: '.Length)
            $broadcastData = $broadcastData.Substring(0, $extrasIndex)
        }
        else {
            if ($broadcastData.EndsWith('"')) {
                $broadcastData = $broadcastData.Substring(0, $broadcastData.Length - 1)
            }
        }

        $broadcastData = $broadcastData -replace '\"', '"'
    }

    $broadcastOuput = [PSCustomObject]@{
        Result = $broadCastResult
        Data   = $broadcastData
        Extras = $broadcastExtras
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
