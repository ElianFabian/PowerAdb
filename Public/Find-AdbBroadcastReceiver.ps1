function Find-AdbBroadcastReceiver {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent,

        [switch] $Raw
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 24

    Assert-ValidIntent -DeviceId $DeviceId -Intent $Intent

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $intentArgs = $Intent.ToAdbArguments($DeviceId)

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm query-receivers --brief --components$userArg$intentArgs" -Verbose:$VerbosePreference `
    | ForEach-Object {
        if ('No receivers found' -eq $_) {
            return $null
        }
        if ('Error: Could not access the Package Manager.  Is the system running?' -eq $_) {
            Write-Error $_ -ErrorAction Stop
        }

        if ($Raw) {
            $_
        }
        else {
            $package, $component = $_.Split('/')
            [PSCustomObject]@{
                PackageName        = $package
                ComponentClassName = $component
            }
        }
    }
}
