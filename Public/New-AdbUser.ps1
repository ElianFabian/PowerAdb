function New-AdbUser {

    [OutputType([int[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $UserName
    )

    begin {
        $userSucessText = 'Success: created user id '
    }

    process {
        foreach ($id in $DeviceId) {
            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell pm create-user '$UserName'" -Verbose:$VerbosePreference

            if ( $result -and $rawResult.StartsWith($userSucessText)) {
                [int] $rawResult.Substring($userSucessText.Length)
            }
        }
    }
}
