function Test-AdbDarkMode {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false

    if ($apiLevel -ge 30) {
        Get-AdbServiceDump -DeviceId $DeviceId -Name 'uimode' -Verbose:$VerbosePreference `
        | Select-String -Pattern 'mComputedNightMode=(false|true)' `
        | ForEach-Object { [bool]::Parse($_.Matches[0].Groups[1].Value) }
    }
    elseif ($apiLevel -ge 29) {
        $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell cmd uimode night" -Verbose:$VerbosePreference
        switch ($result) {
            'Night mode: yes' { $true }
            'Night mode: no' { $false }
            default {
                $device = Resolve-AdbDevice -DeviceId $DeviceId
                Write-Error "Couldn't determine if device with id '$device' is in dark mode or not. Output: $result" -ErrorAction Stop
            }
        }
    }
    else {
        $false
    }
}
