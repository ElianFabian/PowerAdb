function New-AdbUser {

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $UserName
    )

    process {
        foreach ($id in $DeviceId) {
            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell pm create-user '$UserName'" -Verbose:$VerbosePreference

            if ( $result -and $rawResult.StartsWith('Success: created user id ')) {
                [int] $rawResult.Substring('Success: created user id '.Length)
            }
        }
    }
}
