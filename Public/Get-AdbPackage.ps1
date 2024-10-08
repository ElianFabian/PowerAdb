function Get-AdbPackage {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    begin {
        # Length of 'package:'
        $packagePrefixStrLength = 8
    }

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list packages" -Verbose:$VerbosePreference `
        | Out-String -Stream `
        | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
        | ForEach-Object { $_.Substring($packagePrefixStrLength) }
    }
}

# TODO: We might implement this
# list packages [-f] [-d] [-e] [-s] [-3] [-i] [-l] [-u] [-U]
#       [--show-versioncode] [--apex-only] [--uid UID] [--user USER_ID] [FILTER]
#     Prints all packages; optionally only those whose name contains
#     the text in FILTER.  Options are:
#       -f: see their associated file
#       -a: all known packages (but excluding APEXes)
#       -d: filter to only show disabled packages
#       -e: filter to only show enabled packages
#       -s: filter to only show system packages
#       -3: filter to only show third party packages
#       -i: see the installer for the packages
#       -l: ignored (used for compatibility with older releases)
#       -U: also show the package UID
#       -u: also include uninstalled packages
#       --show-versioncode: also show the version code
#       --apex-only: only show APEX packages
#       --uid UID: filter to only show packages with the given UID
#       --user USER_ID: only list packages belonging to the given user
