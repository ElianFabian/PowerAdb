# https://www.redhat.com/en/blog/create-delete-files-directories-linux
function New-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

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
            if (($Force -or -not (Test-AdbPath -SerialNumber $SerialNumber -LiteralRemotePath $LiteralRemotePath))) {
                Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell$runAsCommand echo $sanitizedValue ``>`` '$LiteralRemotePath'" -Verbose:$VerbosePreference
            }
            else {
                Write-Error "File '$LiteralRemotePath' already exists on device with serial number '$SerialNumber'." -Category ResourceExists
            }
        }
        'Directory' {
            if ($Force -or -not (Test-AdbPath -SerialNumber $SerialNumber -LiteralRemotePath $LiteralRemotePath)) {
                Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell$runAsCommand mkdir '$LiteralRemotePath'" -Verbose:$VerbosePreference
            }
            else {
                Write-Error "Directory '$LiteralRemotePath' already exists on device with serial number '$SerialNumber'." -Category ResourceExists
            }
        }
    }
}
