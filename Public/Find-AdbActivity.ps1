function Find-AdbActivity {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId,

        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    begin {
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
        $intentArgs = $Intent.ToAdbArguments()
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell pm query-activities --brief --components $userArg$intentArgs" -Verbose:$VerbosePreference
        }
    }
}

# TODO: Add support for --query-flags
# query-activities [--brief] [--components] [--query-flags FLAGS]
#      [--user USER_ID] INTENT
#   Prints all activities that can handle the given INTENT.
