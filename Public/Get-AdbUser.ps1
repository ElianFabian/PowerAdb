function Get-AdbUser {

    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell pm list users' -Verbose:$VerbosePreference `
    | Select-Object -Skip 1 `
    | Where-Object { $_ } `
    | ForEach-Object {
        $line = $_.Trim()

        $rawContent = $line | Select-String -Pattern 'UserInfo{(.+)}' | ForEach-Object { $_.Matches[0].Groups[1].Value }

        $components = $rawContent.Split(':')

        $userId = $components[0]
        $name = $components[1]
        $flags = $components[2]

        $output = [PSCustomObject] @{
            Id    = [int] $userId
            Name  = $name
            Flags = $flags
        }

        $output | Add-Member -MemberType ScriptProperty -Name 'IntFlags' -Value {
            [System.Convert]::ToInt32($this.Flags, 16)
        }

        $output
    }
}
