function New-AdbNotificationMessage {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $SenderName,

        [string] $Content
    )

    [PSCustomObject]@{
        SenderName = $SenderName
        Content    = $Content
    }
}
