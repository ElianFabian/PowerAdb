function Resolve-AdbUser {

    [OutputType([int], [string])]
    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [AllowNull()]
        [object] $UserId,

        [switch] $CurrentUserAsNull,

        [int] $RequireApiLevel = 17
    )

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false
    if ($apiLevel -lt $RequireApiLevel) {
        if ($UserId -match '^\d+$' -and $UserId -ne 0) {
            $callingFunctionName = Get-PSCallStack | Select-Object -SkipLast 1 -ExpandProperty Command | Select-Object -Last 1
            Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17 -FeatureName "$callingFunctionName -UserId"
        }
        return
    }
    if ($null -eq $UserId) {
        if ($CurrentUserAsNull) {
            # Not all commands accept 'current' (e.g, adb shell content)
            return $null
        }

        # Default is 'current' for a more standard behavior across all API levels.
        return 'current'
    }
    if ($UserId -notmatch '^\d+$' -and $UserId -ne 'current') {
        Write-Error -Message "UserId must be a whole positive number or 'current', but was '$UserId'." -ErrorAction Stop
    }
    if ($UserId -eq 'current') {
        return 'current'
    }

    return [int] $UserId
}
