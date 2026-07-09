function Get-AdbDisplayMetrics {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    # 'display' service was added in API level 17
    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $displayDump = Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'display' -Verbose:$VerbosePreference
    $dumpText = $displayDump -join "`n"

    $hwWidth = $hwHeight = 0
    if ($dumpText -match 'mStableDisplaySize=Point\((?<w>\d+),\s*(?<h>\d+)\)') {
        $hwWidth = [int]$Matches['w']
        $hwHeight = [int]$Matches['h']
    }
    elseif ($dumpText -match 'mDefaultViewport=DisplayViewport\{[^}]+deviceWidth=(?<w>\d+),\s*deviceHeight=(?<h>\d+)') {
        $hwWidth = [int]$Matches['w']
        $hwHeight = [int]$Matches['h']
    }

    $activeWidth = $activeHeight = 0
    $activeDensity = 0.0
    if ($dumpText -match 'mActiveSfDisplayMode=DisplayMode\{[^}]+width=(?<w>\d+),\s*height=(?<h>\d+),\s*xDpi=(?<dpi>[\d.]+)') {
        $activeWidth = [int]$Matches['w']
        $activeHeight = [int]$Matches['h']
        $activeDensity = [double]$Matches['dpi']
    }
    elseif ($dumpText -match 'DisplayDeviceInfo\{"[^"]+":\s*(?:uniqueId="[^"]+",\s*)?(?<w>\d+)\s*x\s*(?<h>\d+),.*?(?<dpi>[\d.]+)\s*x\s*[\d.]+\s*dpi') {
        $activeWidth = [int]$Matches['w']
        $activeHeight = [int]$Matches['h']
        $activeDensity = [double]$Matches['dpi']
    }

    $hwDensity = 0.0
    if ($hwWidth -gt 0) {
        if ($dumpText -match "DisplayMode\{[^}]+width=$hwWidth,[^}]+xDpi=(?<dpi>[\d.]+)") {
            $hwDensity = [double]$Matches['dpi']
        }
        elseif ($dumpText -match "PhysicalDisplayInfo\{$hwWidth\s*x\s*\d+,.*?(?<dpi>[\d.]+)\s*x\s*[\d.]+\s*dpi") {
            $hwDensity = [double]$Matches['dpi']
        }
        else {
            $hwDensity = $activeDensity
        }
    }

    $activeRefreshRate = 0.0
    if ($dumpText -match 'renderFrameRate\s+(?<fps>[\d.]+)') {
        $activeRefreshRate = [double]$Matches['fps']
    }
    elseif ($dumpText -match 'PhysicalDisplayInfo\{[^,]+,\s*(?<fps>[\d.]+)\s*fps') {
        $activeRefreshRate = [double]$Matches['fps']
    }
    elseif ($dumpText -match 'fps=(?<fps>[\d.]+)') {
        $activeRefreshRate = [double]$Matches['fps']
    }

    $supportedRates = @()
    if ($dumpText -match 'supportedRefreshRates\s*\[(?<rates>[^\]]+)\]') {
        [int[]] $supportedRates = $Matches['rates'] -split ',' | ForEach-Object { 
            [int][math]::Round([double]$_.Trim()) 
        } | Sort-Object -Descending
    }
    elseif ($dumpText -match 'supportedModes\s*\[(?<content>[^\]]+)\]') {
        [int[]] $supportedRates = [regex]::Matches($Matches['content'], 'fps=(?<fps>[\d.]+)') | ForEach-Object {
            [int][math]::Round([double]$_.Groups['fps'].Value)
        } | Select-Object -Unique | Sort-Object -Descending
    }

    if ($supportedRates.Count -eq 0 -and $activeRefreshRate -gt 0) {
        [int[]] $supportedRates = [int][math]::Round($activeRefreshRate)
    }

    $orientation = "Unknown"
    if ($dumpText -match 'orientation=(?<ori>\d+)') {
        switch ([int] $Matches['ori']) {
            0 { $orientation = 'Portrait' }
            1 { $orientation = 'Landscape' }
            2 { $orientation = 'ReversePortrait' }
            3 { $orientation = 'ReverseLandscape' }
        }
    }

    $uiDensity = 0
    if ($dumpText -match 'densityDpi=(?<dpi>\d+)') {
        $uiDensity = [int]$Matches['dpi']
    }
    elseif ($dumpText -match 'density\s+(?<dpi>\d+)\s*[,(]') {
        $uiDensity = [int]$Matches['dpi']
    }

    $diagonal = 0.0
    $physicalWidthCm = 0.0
    $physicalHeightCm = 0.0

    if ($activeWidth -gt 0 -and $activeHeight -gt 0 -and $activeDensity -gt 0) {
        $widthInInch = $activeWidth / $activeDensity
        $heightInInch = $activeHeight / $activeDensity
        
        $diagonal = [math]::Sqrt(($widthInInch * $widthInInch) + ($heightInInch * $heightInInch))
        $physicalWidthCm = [math]::Round($widthInInch * 2.54, 2)
        $physicalHeightCm = [math]::Round($heightInInch * 2.54, 2)
    }

    return [PSCustomObject]@{
        SerialNumber          = Get-AdbSerialNumber -SerialNumber $SerialNumber
        Orientation           = $orientation
        ActiveRefreshRateHz   = [math]::Round($activeRefreshRate)
        SupportedRefreshRates = $supportedRates
        ActiveWidth           = $activeWidth
        ActiveHeight          = $activeHeight
        ActiveDensity         = $activeDensity
        UiDensityDpi          = $uiDensity
        HardwareWidth         = $hwWidth
        HardwareHeight        = $hwHeight
        HardwareDensity       = $hwDensity
        PhysicalWidthCm       = $physicalWidthCm
        PhysicalHeightCm      = $physicalHeightCm
        DiagonalInches        = [math]::Round($diagonal, 2)
    }
}
