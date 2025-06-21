function Send-AdbEmulatorSms {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        # According to docs this is the phone number, but it seems we can send any kind of string.
        [Parameter(Mandatory)]
        [string] $SenderName,

        # To send new lines use '\n'
        [Parameter(Mandatory)]
        [string] $Message
    )

    Assert-ValidAdbStringArgument $SenderName -ArgumentName 'SenderName'
    Assert-ValidAdbStringArgument $Message -ArgumentName 'Message'
    if ($SenderName.Contains(' ')) {
        Write-Error "SenderName can't contain spaces. SenderName: '$SenderName'." -ErrorAction Stop
    }

    Invoke-EmuExpression -SerialNumber $SerialNumber -Command "sms send '$SenderName' '$Message'" -Verbose:$VerbosePreference
}
