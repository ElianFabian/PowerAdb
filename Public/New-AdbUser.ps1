function New-AdbUser {

    [OutputType([int])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $UserName
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    $sanitizedUserName = ConvertTo-ValidAdbStringArgument $UserName
    $rawResult = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm create-user $sanitizedUserName" -Verbose:$VerbosePreference

    $userSucessText = 'Success: created user id '
    if ($rawResult -and $rawResult.StartsWith($userSucessText)) {
        [int] $rawResult.Substring($userSucessText.Length)
    }
}
