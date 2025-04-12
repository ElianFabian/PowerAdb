# https://www.redhat.com/en/blog/create-delete-files-directories-linux
function New-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [ValidateSet('File', 'Directory')]
        [string] $Type = 'File',

        [string] $Value,

        [switch] $Force
    )

    if ($RunAs) {
        $runAsCommand = " run-as '$RunAs'"
    }

    $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value

    switch ($Type) {
        'File' {
            if (($Force -or -not (TestItem -DeviceId $DeviceId -LiteralRemotePath $LiteralRemotePath))) {
                Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand echo $sanitizedValue ``>`` '$LiteralRemotePath'" -Verbose:$VerbosePreference
            }
            else {
                Write-Error "File '$LiteralRemotePath' already exists on device with id '$DeviceId'." -Category ResourceExists
            }
        }
        'Directory' {
            if ($Force -or -not (TestItem -DeviceId $DeviceId -LiteralRemotePath $LiteralRemotePath)) {
                Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runAsCommand mkdir '$LiteralRemotePath'" -Verbose:$VerbosePreference
            }
            else {
                Write-Error "Directory '$LiteralRemotePath' already exists on device with id '$DeviceId'." -Category ResourceExists
            }
        }
    }
}

function TestItem {

    param (
        [string] $DeviceId,
        [string] $LiteralRemotePath
    )

    return (adb -s $DeviceId "shell" "[ -e '$LiteralRemotePath' ] && echo '1' || echo '0'") -eq '1'
}
