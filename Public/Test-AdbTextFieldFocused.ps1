function Test-AdbTextFieldFocused {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    if (Get-AdbScreenViewContent | Select-Xml -XPath '//node[@focused="true"]') {
        return $true
    }

    return $false
}
