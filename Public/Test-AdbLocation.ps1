function Test-AdbLocation {

    [OutputType([bool[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -ge 29) {
                $locationMode = Get-AdbSetting -DeviceId $id -Namespace Secure -Key 'location_mode' -Verbose:$VerbosePreference
                switch ($locationMode) {
                    3 { $true }
                    0 { $false }
                }
            }
            elseif ($apiLevel -ge 17) {
                $locationProviders = Get-AdbSetting -DeviceId $id -Namespace Secure -Key 'location_providers_allowed' -Verbose:$VerbosePreference `
                | Select-Object -Last 1 # To avoid including the message 'WARNING: linker: libdvm.so has text relocations. This is wasting memory and is a security risk. Please fix.'

                $locationProviders -ceq 'gps,network' -or $locationProviders -ceq 'gps' -or $locationProviders -ceq 'network'
            }
            else {
                Write-Error "Unsupported API level: '$apiLevel'. Only API levels 17 and above are supported."
            }
        }
    }
}



# Results from experimenting with emulators
# Android Location Mode and Providers Overview
# -------------------------------------------------------------------------------------------------------------------------
# API Level | location_mode (ON) | location_mode (OFF) | location_providers_allowed (ON) | location_providers_allowed (OFF)
# -------------------------------------------------------------------------------------------------------------------------
# 17        | 3                  | 3                   | gps,network (3)                 | -
# 18        | null               | null                | gps,network (3)                 | -
# 19        | null               | null                | gps,network (3)                 | -
# 21        | null               | null                | gps,network (3)                 | -
# 22        | null               | null                | gps,network (3)                 | -
# 23        | null               | null                | gps,network (3)                 | -
# 24        | null               | null                | gps,network (3)                 | -
# 25        | null               | null                | gps,network (3)                 | -
# 26        | null               | null                | gps,network (3)                 | -
# 27        | null               | null                | gps,network (3)                 | -
# 28        | null               | null                | gps,network (2)                 | -
# 29        | 3                  | 0                   | gps,network (2)                 | -
# 30        | 3                  | 0                   | gps,network (2)                 | -
# 31        | 3                  | 0                   | null                            | null
# 32        | 3                  | 0                   | null                            | null
# 33        | 3                  | 0                   | null                            | null
# 34        | 3                  | 0                   | gps                             | gps
# 35        | 3                  | 0                   | gps                             | gps
#
# Explanation of location_providers_allowed possible values:
# ----------------------------------------------------------
# gps,network (3)   | GPS-Network, Network and GPS
# gps,network (2)   | GPS-Network and GPS
# gps               | Only GPS
