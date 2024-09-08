function Send-AdbText {

    # These ( ) < > | ; & * \ ~ " ' ` % and 'space' all need escaping. Space is replaced with %s
    # https://stackoverflow.com/a/31371987/18418162

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Text
    )

    begin {
        if (Compare-Object -ReferenceObject ([System.Text.Encoding]::ASCII.GetBytes($Text)) -DifferenceObject ([System.Text.Encoding]::Latin1.GetBytes($Text))) {
            Write-Error "'adb shell input text' only accepts latin1 characters. Text: '$Text'"
            return $null
        }
    }

    process {
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

            $encodedText = $sb.ToString()

            Invoke-AdbExpression -DeviceId $id -Command "shell input text ""$encodedText"""
        }
    }
}
