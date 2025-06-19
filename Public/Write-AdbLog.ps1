function Write-AdbLog {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Message,

        [string] $Tag,

        [ValidateSet(
            'Debug',
            'Error',
            'Fatal',
            'Info',
            'Verbose',
            'Warn',
            'Silent'
        )]
        [string] $Priority = 'Info'
    )

    if ($Priority -eq 'Silent') {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 26 -FeatureName "$($MyInvocation.MyCommand.Name) -Priority Silent"
    }

    $priorityArgValue = switch ($Priority) {
        'Debug' { 'd' }
        'Error' { 'e' }
        'Fatal' { 'f' }
        'Info' { 'i' }
        'Verbose' { 'v' }
        'Warn' { 'w' }
        'Silent' { 's' }
    }

    $priorityArg = " -p '$priorityArgValue'"

    if ($Tag) {
        $sanitizedTag = ConvertTo-ValidAdbStringArgument $Tag
        $tagArg = " -t $sanitizedTag"
    }

    $sanitizedMessage = ConvertTo-ValidAdbStringArgument $Message

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell log$priorityArg$tagArg $sanitizedMessage" -Verbose:$VerbosePreference > $null
}
