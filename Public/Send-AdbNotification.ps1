function Send-AdbNotification {

    # https://android.googlesource.com/platform/frameworks/base/+/master/services/core/java/com/android/server/notification/NotificationShellCmd.java

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [string] $Tag,

        [string] $Title,

        [string] $Content,

        # file:///data/local/tmp/<img.png> (e.g. 'file:///data/local/tmp/screenshot.png', 'file://' prefix is optional)
        # content://<provider>/<path> (e.g. 'content://media/external/images/media/123')
        # @[<package>:]drawable/<img> (e.g. '@android:drawable/sym_action_chat', '@android:drawable/stat_notify_chat')
        # data:base64,<B64DATA==> (e.g. 'data:base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII')
        [string] $Icon,

        # file:///data/local/tmp/<img.png>
        # content://<provider>/<path>
        # @[<package>:]drawable/<img>
        # data:base64,<B64DATA==>
        [string] $LargeIcon,

        [Parameter(ParameterSetName = 'BigTextStyle')]
        [switch] $BigTextStyle,

        [Parameter(ParameterSetName = 'MediaStyle')]
        [switch] $MediaStyle,

        # File and content URIs aren't supported, only drawables and base64 images.
        # @[<package>:]drawable/<img>
        # data:base64,<B64DATA==>
        [Parameter(ParameterSetName = 'BigPictureStyle')]
        [string] $BigPicture,

        [Parameter(Mandatory, ParameterSetName = 'InboxStyle')]
        [string[]] $InboxLine,

        [Parameter(Mandatory, ParameterSetName = 'MessagingStyle')]
        [string] $ConversationTitle,

        [Parameter(Mandatory, ParameterSetName = 'MessagingStyle')]
        [scriptblock] $ConversationMessage


        # --content-intent doesn't seem to work: 'Error occurred. Check logcat for details. Permission Denial: getIntentSender() from pid=26724, uid=2000 is not allowed to send as package android'
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqual 29

    $argsSb = [System.Text.StringBuilder]::new()

    if ($VerbosePreference -eq 'Continue') {
        $argsSb.Append(' --verbose') > $null
    }
    if ($Title) {
        $argsSb.Append(" --title $(ConvertTo-ValidAdbStringArgument $Title)") > $null
    }
    if ($Icon) {
        $argsSb.Append(" --icon $(ConvertTo-ValidAdbStringArgument $Icon)") > $null
    }
    if ($LargeIcon) {
        $argsSb.Append(" --large-icon $(ConvertTo-ValidAdbStringArgument $LargeIcon)") > $null
    }
    switch ($PSCmdlet.ParameterSetName) {
        'BigTextStyle' {
            $argsSb.Append(' --style bigtext') > $null
        }
        'MediaStyle' {
            $argsSb.Append(' --style media') > $null
        }
        'BigPictureStyle' {
            if ($BigPicture.StartsWith('file://') -or $BigPicture.StartsWith('content://')) {
                Write-Error "BigPicture only works with base64 and drawables images: '$BigPicture'" -ErrorAction Stop
            }
            $argsSb.Append(" --style bigpicture --picture $(ConvertTo-ValidAdbStringArgument $BigPicture)") > $null
        }
        'InboxStyle' {
            $argsSb.Append(' --style inbox') > $null
            foreach ($line in $InboxLine) {
                $argsSb.Append(" --line $(ConvertTo-ValidAdbStringArgument $line)") > $null
            }
        }
        'MessagingStyle' {
            $argsSb.Append(' --style messaging') > $null
            $argsSb.Append(" --conversation $(ConvertTo-ValidAdbStringArgument $ConversationTitle)") > $null
            foreach ($message in $ConversationMessage.Invoke()) {
                if (-not ($message -is [PSCustomObject])) {
                    Write-Error "Invalid message object: '$message'. Expected a PSCustomObject." -ErrorAction Stop
                }
                if (-not ($message.SenderName -and $message.Content)) {
                    Write-Error "Invalid message object: '$message'. Expected properties UserName and Text." -ErrorAction Stop
                }
                $argsSb.Append(" --message $(ConvertTo-ValidAdbStringArgument "$($message.SenderName):$($message.Content)")") > $null
            }
        }
    }

    $argsSb.Append(" $(ConvertTo-ValidAdbStringArgument $Tag)") > $null
    $argsSb.Append(" $(ConvertTo-ValidAdbStringArgument $Content)") > $null

    $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd notification post$argsSb" -Verbose:$VerbosePreference
    if ($VerbosePreference -eq 'Continue') {
        foreach ($line in $result) {
            Write-Verbose $line
        }
    }
    else {
        Write-Host "$result" -ForegroundColor Green
    }
}
