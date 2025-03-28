function Get-AdbUser {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    foreach ($id in $DeviceId) {
        Invoke-AdbExpression -DeviceId $id -Command 'shell pm list users' -Verbose:$VerbosePreference `
        | Select-Object -Skip 1 `
        | ForEach-Object {
            $line = $_.Trim()

            $rawContent = $line | Select-String -Pattern 'UserInfo{(.+)}' | ForEach-Object { $_.Matches[0].Groups[1].Value }

            $components = $rawContent.Split(':')

            $userId = $components[0]
            $name = $components[1]
            $flags = $components[2]

            $output = [PSCustomObject] @{
                DeviceId = $id
                Id = [int] $userId
                Name = $name
                Flags = $flags
            }

            $output | Add-Member -MemberType ScriptProperty -Name 'IntFlags' -Value {
                [System.Convert]::ToInt32($this.Flags, 16)
            }

            $output
        }
    }
}
