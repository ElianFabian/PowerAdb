function Write-AdbLog {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

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

    begin {
        $priorityArgValue = switch ($Priority) {
            'Debug' { 'd' }
            'Error' { 'e' }
            'Fatal' { 'f' }
            'Info' { 'i' }
            'Verbose' { 'v' }
            'Warn' { 'w' }
            'Silent' { 's' }
        }

        $priorityArg = "-p '$priorityArgValue'"

        if ($Tag) {
            $tagArg = "-t '$Tag'"
        }

        $sanitizedMessage = ConvertTo-ValidAdbStringArgument $Message
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell log $priorityArg $tagArg $sanitizedMessage" -Verbose:$VerbosePreference > $null
        }
    }
}
