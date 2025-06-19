function New-AdbNotificationMessage {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $SenderName,

        [string] $Content
    )

    if ($SenderName.Contains(':')) {
        Write-Error "The SenderName cannot contain a colon (':'). Input: '$SenderName'" -ErrorAction Stop
    }

    [PSCustomObject]@{
        SenderName = $SenderName
        Content    = $Content
    }
}
