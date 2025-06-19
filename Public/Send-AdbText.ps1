function Send-AdbText {

    # These ( ) < > | ; & * \ ~ " ' ` % and 'space' all need escaping. Space is replaced with %s
    # https://stackoverflow.com/a/31371987/18418162

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Text,

        [switch] $Force
    )

    if ((Compare-Object -ReferenceObject ($script:Ascii.GetBytes($Text)) -DifferenceObject ($script:Latin1.GetBytes($Text))) -and -not $Force) {
        Write-Error "'$($MyInvocation.MyCommand)' only accepts ASCII characters. Use the '-Force' switch to override this restriction." -ErrorAction Stop
    }

    $sanitizedText = ConvertTo-ValidAdbStringArgument $Text

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell input text $sanitizedText" -Verbose:$VerbosePreference
}



$script:Ascii = [System.Text.Encoding]::ASCII
$script:Latin1 = [System.Text.Encoding]::GetEncoding("ISO-8859-1")
