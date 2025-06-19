function Get-AdbServiceDump {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'Name')]
        [string] $Name,

        [Parameter(ParameterSetName = 'Name')]
        [string[]] $ArgumentList
    )

    if ($Name) {
        if ($Name.Contains(' ')) {
            Write-Error "Names can't contain spaces. Name: '$Name'" -ErrorAction Stop
        }
        $nameArg = " $Name"
    }
    if ($ArgumentList) {
        $serviceArgList = " $(($ArgumentList | ForEach-Object {
            if ($_.Contains(' ')) {
                Write-Error "Arguments can't contain spaces. Name: '$_'" -ErrorAction Stop
            }
            $_
        }) -join ' ')"
    }

    $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell dumpsys$nameArg$serviceArgList" -Verbose:$VerbosePreference

    if ($result -match 'Bad \w+ command, or no \w+ match: \w+') {
        Write-Error -Message ($result -join "`n") -ErrorAction Stop
    }

    return $result
}
