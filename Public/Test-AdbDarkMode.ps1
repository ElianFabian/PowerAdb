function Test-AdbDarkMode {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false

    if ($apiLevel -ge 30) {
        Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'uimode' -Verbose:$VerbosePreference `
        | Select-String -Pattern 'mComputedNightMode=(false|true)' `
        | ForEach-Object { [bool]::Parse($_.Matches[0].Groups[1].Value) }
    }
    elseif ($apiLevel -ge 29) {
        $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd uimode night" -Verbose:$VerbosePreference
        switch ($result) {
            'Night mode: yes' { $true }
            'Night mode: no' { $false }
            default {
                $serial = Resolve-AdbDevice -SerialNumber $SerialNumber
                Write-Error "Couldn't determine if device with serial number '$serial' is in dark mode or not. Output: $result" -ErrorAction Stop
            }
        }
    }
    else {
        $false
    }
}
