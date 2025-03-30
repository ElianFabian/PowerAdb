function Find-AdbService {

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
            Invoke-AdbExpression -DeviceId $id -Command "shell pm query-services --brief --components $userArg$intentArgs" -Verbose:$VerbosePreference
        }
    }
}

# TODO: Add support for --query-flags
# query-services [--brief] [--components] [--query-flags FLAGS]
#       [--user USER_ID] INTENT
#    Prints all services that can handle the given INTENT.
