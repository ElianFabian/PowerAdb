function New-AdbUser {

    [OutputType([int])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $UserName
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $sanitizedUserName = ConvertTo-ValidAdbStringArgument $UserName
    $rawResult = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm create-user $sanitizedUserName" -Verbose:$VerbosePreference

    $userSucessText = 'Success: created user id '
    if ($rawResult -and $rawResult.StartsWith($userSucessText)) {
        [int] $rawResult.Substring($userSucessText.Length)
    }
}
