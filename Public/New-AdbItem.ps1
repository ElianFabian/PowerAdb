# https://www.redhat.com/en/blog/create-delete-files-directories-linux
function New-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [ValidateSet('File', 'Directory')]
        [string] $Type = 'File',

        [string] $Value,

        [switch] $Force
    )

    begin {
        if ($RunAs) {
            $runAsCommand = " run-as '$RunAs'"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            switch ($Type) {
                'File' {
                    if (($Force -or -not (TestItem -DeviceId $id -LiteralRemotePath $LiteralRemotePath))) {
                        Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand ""echo '$Value' > '$LiteralRemotePath'"""  -Verbose:$VerbosePreference
                    }
                    else {
                        Write-Error "File '$LiteralRemotePath' already exists on device with id '$id'." -Category ResourceExists
                    }
                }
                'Directory' {
                    if ($Force -or -not (TestItem -DeviceId $id -LiteralRemotePath $LiteralRemotePath)) {
                        Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand mkdir '$LiteralRemotePath'" -Verbose:$VerbosePreference
                    }
                    else {
                        Write-Error "Directory '$LiteralRemotePath' already exists on device with id '$id'." -Category ResourceExists
                    }
                }
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
