function Install-AdbApplication {

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string[]] $Path,

        [Parameter(Mandatory, ParameterSetName = 'LiteralPath')]
        [string[]] $LiteralPath,

        [Parameter(Mandatory)]
        [switch] $Replace

        # It seems that in some API levels this does not exist, even though
        # it appears on the adb help in the version it doesn't work
        # I won't add it yet
        # [Parameter(Mandatory)]
        # [switch] $GrantAllRantimePermissions
    )

    begin {
        # In certain phones or probably APIs the default behavior is to prevent installing
        # if the app is already installed
        if ($Replace) {
            $replaceParam = "-r "
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $items = switch ($PSCmdlet.ParameterSetName) {
                Path { Get-Item -Path $Path }
                LiteralPath { Get-Item -LiteralPath $LiteralPath }
            }
            foreach ($item in $items) {
                $itemPath = $item.FullName
                Invoke-AdbExpression -DeviceId $id -Command "install $replaceParam'$itemPath'"
            }
        }
    }
}
