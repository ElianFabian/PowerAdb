function Get-AdbDiskInfo {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys diskstats" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Out-String `
            | Select-String -Pattern $diskInfoPattern -AllMatches `
            | Select-Object -ExpandProperty Matches `
            | ForEach-Object {
                $groups = $_.Groups[0].Captures[0].Groups

                $packageNames = $groups['packageNamesStr'].Value.Split(',').Trim() | ForEach-Object { $_.Trim('"') }
                $appSizes = $groups['appSizesStr'].Value.Split(',').Trim() | ForEach-Object { [uint64] $_ }
                $appDataSizes = $groups['appDataSizesStr'].Value.Split(',').Trim() | ForEach-Object { [uint64] $_ }
                $cacheSizes = $groups['cacheSizesStr'].Value.Split(',').Trim() | ForEach-Object { [uint64] $_ }

                $fileBasedEncryption = $groups['fileBasedEncryption'].Value
                $appSize = $groups['appSize'].Value
                $appDataSize = $groups['appDataSize'].Value
                $appCacheSize = $groups['appCacheSize'].Value
                $photosSize = $groups['photosSize'].Value
                $videosSize = $groups['videosSize'].Value
                $audioSize = $groups['audioSize'].Value
                $downloadsSize = $groups['downloadsSize'].Value
                $systemSize = $groups['systemSize'].Value
                $otherSize = $groups['otherSize'].Value

                [PSCustomObject]@{
                    DeviceId            = $id
                    DataFree            = ([uint64] $groups['dataFreeInKb'].Value) * 1024
                    DataTotal           = ([uint64] $groups['dataTotalInKb'].Value) * 1024
                    CacheFree           = ([uint64] $groups['cacheFreeInKb'].Value) * 1024
                    SystemFree          = ([uint64] $groups['systemFreeInKb'].Value) * 1024
                    SystemTotal         = ([uint64] $groups['systemTotalInKb'].Value) * 1024
                    FileBasedEncryption = if ($fileBasedEncryption) { [bool]::Parse($fileBasedEncryption) } else { $null }
                    AppSize             = if ($appSize) { [uint64] $appSize } else { $null }
                    AppDataSize         = if ($appDataSize) { [uint64] $appDataSize } else { $null }
                    AppCacheSize        = if ($appCacheSize) { [uint64] $appCacheSize } else { $null }
                    PhotosSize          = if ($photosSize) { [uint64] $photosSize } else { $null }
                    VideosSize          = if ($videosSize) { [uint64] $videosSize } else { $null }
                    AudioSize           = if ($audioSize) { [uint64] $audioSize } else { $null }
                    DownloadsSize       = if ($downloadsSize) { [uint64] $downloadsSize } else { $null }
                    SystemSize          = if ($systemSize) { [uint64] $systemSize } else { $null }
                    OtherSize           = if ($otherSize) { [uint64] $otherSize } else { $null }
                    InstalledApps       = for ($i = 0; $i -lt $packageNames.Count; $i++) {
                        [PSCustomObject]@{
                            PackageName = $packageNames[$i]
                            AppSize     = $appSizes[$i]
                            AppDataSize = $appDataSizes[$i]
                            CacheSize   = $cacheSizes[$i]
                        }
                    }
                }
            }
        }
    }
}



$diskInfoPattern = @"
Data-Free: (?<dataFreeInKb>\d+)K / (?<dataTotalInKb>\d+)K.+(\r?\n)+
Cache-Free: (?<cacheFreeInKb>\d+)K.+(\r?\n)+
System-Free: (?<systemFreeInKb>\d+)K / (?<systemTotalInKb>\d+)K.+(\r?\n)+
(
File-based Encryption: (?<fileBasedEncryption>true|false)\r?\n
App Size: (?<appSize>\d+)\r?\n
App Data Size: (?<appDataSize>\d+)\r?\n
App Cache Size: (?<appCacheSize>\d+)\r?\n
Photos Size: (?<photosSize>\d+)\r?\n
Videos Size: (?<videosSize>\d+)\r?\n
Audio Size: (?<audioSize>\d+)\r?\n
Downloads Size: (?<downloadsSize>\d+)\r?\n
System Size: (?<systemSize>\d+)\r?\n
Other Size: (?<otherSize>\d+)\r?\n
Package Names: \[(?<packageNamesStr>.+)\]\r?\n
App Sizes: \[(?<appSizesStr>.+)\]\r?\n
App Data Sizes: \[(?<appDataSizesStr>.+)\]\r?\n
Cache Sizes: \[(?<cacheSizesStr>.+)\]
)?
"@.Replace("`r`n", "").Replace("`n", "")
