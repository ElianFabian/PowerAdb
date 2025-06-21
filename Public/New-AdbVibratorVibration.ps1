function New-AdbVibratorVibration {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int] $Id,

        [Parameter(Mandatory = $false, Position = 0)]
        [scriptblock] $Vibration
    )

    if (-not $Vibration -and $args.Count -gt 0 -and $args[0] -is [ScriptBlock]) {
        $Vibration = $args[0]
    }

    $output = [PSCustomObject]@{
        Id        = $Id
        Vibration = $Vibration
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        $vibrationsString = ($this.Vibration.Invoke() | ForEach-Object { $_.ToAdbArguments() }) -join ''

        return " -v $($this.Id)$vibrationsString"
    }

    return $output
}
