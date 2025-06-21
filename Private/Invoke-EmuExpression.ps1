function Invoke-EmuExpression {

    [OutputType([string])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [string] $Command
    )

    begin {
        $previous = $null
    }

    process {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "emu $Command" -Verbose:$VerbosePreference `
        | Where-Object { $_ } `
        | ForEach-Object {
            if ($null -ne $previous) {
                $previous
            }
            $previous = $_
        }
    }

    end {
        Write-Verbose $previous
    }
}
