function Send-AdbText {

    # These ( ) < > | ; & * \ ~ " ' ` % and 'space' all need escaping. Space is replaced with %s
    # https://stackoverflow.com/a/31371987/18418162

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Text,

        [switch] $Force
    )

    begin {
        if ((Compare-Object -ReferenceObject ($script:Ascii.GetBytes($Text)) -DifferenceObject ($script:Latin1.GetBytes($Text))) -and -not $Force) {
            Write-Error "'$($MyInvocation.MyCommand)' only accepts ASCII characters. Use the '-Force' switch to override this restriction. Text: $Text"
            $skip = $true
        }
    }

    process {
        if ($skip) {
            return
        }

        foreach ($id in $DeviceId) {
            $sb = [System.Text.StringBuilder]::new($Text)

            $sb.Replace('(', '\(') > $null
            $sb.Replace(')', '\)') > $null
            $sb.Replace('<', '\<') > $null
            $sb.Replace('>', '\>') > $null
            $sb.Replace('|', '\|') > $null
            $sb.Replace(';', '\;') > $null
            $sb.Replace('&', '\&') > $null
            $sb.Replace('\', '\\') > $null
            $sb.Replace('~', '\~') > $null
            $sb.Replace("'", "\'") > $null
            $sb.Replace('`', '\`') > $null
            $sb.Replace('%', '\%') > $null
            $sb.Replace(" ", "%s") > $null
            $sb.Replace('"', '\"') > $null

            $encodedText = $sb.ToString()

            Invoke-AdbExpression -DeviceId $id -Command "shell input text '$encodedText'" -Verbose:$VerbosePreference
        }
    }
}


$script:Ascii = [System.Text.Encoding]::ASCII

$script:Latin1 = [System.Text.Encoding]::GetEncoding("ISO-8859-1")
