function Get-AdbDiskInfo {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $output = [PSCustomObject]@{}

    Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'diskstats' -Verbose:$VerbosePreference `
    | Select-String -Pattern $script:RowPattern `
    | ForEach-Object {
        $groups = $_.Matches[0].Groups

        $rawName = $groups['name'].Value
        $name = $rawName.Replace(' ', '').Replace('-', '')

        $rawValue = $groups['value'].Value

        if ($rawValue[0] -eq '[') {
            $value = $rawValue.Trim('[', ']', ' ').Split(',') | ForEach-Object { $_.Trim('"') }
        }
        else {
            $value = $rawValue
        }

        $output | Add-Member -MemberType NoteProperty -Name $name -Value $value -Force
    }

    $output
}



$script:RowPattern = '(?<name>[\w-\s]+)(: | = )(?<value>\S.+)'
