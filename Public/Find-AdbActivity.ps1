function Find-AdbActivity {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent,

        [switch] $Raw
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 24

    Assert-ValidIntent -SerialNumber $SerialNumber -Intent $Intent

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $intentArgs = $Intent.ToAdbArguments($SerialNumber)

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm query-activities --brief --components$userArg$intentArgs" -Verbose:$VerbosePreference `
    | ForEach-Object {
        if ('No activities found' -eq $_) {
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
