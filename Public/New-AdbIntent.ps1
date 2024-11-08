function New-AdbIntent {

    [CmdletBinding()]
    param (
        [string] $Action = $null,

        [uri] $Data = $null,

        [string] $Type = $null,

        [string] $Identifier = $null,

        [string] $Category = $null,

        [string] $ComponentName = $null,

        [ValidateSet(
            'GrantReadUriPermission',
            'GrantWriteUriPermission',
            'FromBackground',
            'DebugLogResolution',
            'ExcludeStoppedPackages',
            'IncludeStoppedPackages',
            'GrantPersistableUriPermission',
            'GrantPrefixUriPermission',
            'DirectBootAuto',
            'DebugTriagedMissing',
            'IgnoreEphemeral',
            'ActivityMatchExternal',
            'ActivityNoHistory',
            'ActivitySingleTop',
            'ActivityNewTask',
            'ActivityMultipleTask',
            'ActivityClearTop',
            'ActivityForwardResult',
            'ActivityPreviousIsTop',
            'ActivityExcludeFromRecents',
            'ActivityBroughtToFront',
            'ActivityResetTaskIfNeeded',
            'ActivityLaunchedFromHistory',
            'ActivityNewDocument',
            'ActivityClearWhenTaskReset',
            'ActivityNoUserAction',
            'ActivityReorderToFront',
            'ActivityNoAnimation',
            'ActivityClearTask',
            'ActivityTaskOnHome',
            'ActivityRetainInRecents',
            'ActivityLaunchAdjacent',
            'ActivityRequireNonBrowser',
            'ActivityRequireDefault',
            'ReceiverRegisteredOnly',
            'ReceiverReplacePending',
            'ReceiverForeground',
            'ReceiverNoAbort',
            'ReceiverRegisteredOnlyBeforeBoot',
            'ReceiverBootUpgrade',
            'ReceiverIncludeBackground',
            'ReceiverExcludeBackground',
            'ReceiverFromShell',
            'ReceiverVisibleToInstantApps',
            'ReceiverOffload',
            'ReceiverOffloadForeground'
        )]
        [string[]] $Flags = $null,

        [string] $Selector = $null,

        [scriptblock] $Bundle = $null
    )

    $intent = [PSCustomObject] @{
        Action        = $Action
        Data          = $Data
        Type          = $Type
        Identifier    = $Identifier
        Category      = $Category
        ComponentName = $ComponentName
        Flags         = $Flags
        Selector      = $Selector
        BundlePairs   = $BundlePairs
    }

    if ($this.Flags) {
        $intFlags = 0
        $Flags | ForEach-Object {
            $intFlags += FlagToInt -Flag $_
        }
    }

    $intent | Add-Member -MemberType NoteProperty -Name IntFlags -Value $intFlags

    $adbArguments = ""
    if ($intent.Action) {
        $adbArguments += " -a $($intent.Action)"
    }
    if ($intent.Data) {
        $adbArguments += " -d '$($intent.Data)'"
    }
    if ($intent.Type) {
        $adbArguments += " -t '$($intent.Type)'"
    }
    if ($intent.Identifier) {
        $adbArguments += " -i '$($intent.Identifier)'"
    }
    if ($intent.Category) {
        $adbArguments += " -n '$($intent.Category)'"
    }
    if ($intent.ComponentName) {
        $adbArguments += " --ecn '$($intent.ComponentName)'"
    }
    if ($intent.Flags) {
        $adbArguments += " -f $($intent.IntFlags)"
    }
    if ($intent.Selector) {
        $adbArguments += " --selector '$($intent.Selector)'"
    }
    if ($intent.BundlePairs) {
        $intent.BundlePairs.Invoke() | ForEach-Object {
            $adbArguments += " $($_.AdbArgument)"
        }
    }

    $intent | Add-Member -MemberType NoteProperty -Name AdbArgument -Value $adbArguments.Trim()

    return $intent
}

function FlagToInt {

    [OutputType([int])]
    param (
        [string] $Flag
    )

    switch ($Flag) {
        'GrantReadUriPermission' { 0x00000001 }
        'GrantWriteUriPermission' { 0x00000002 }
        'FromBackground' { 0x00000004 }
        'DebugLogResolution' { 0x00000008 }
        'ExcludeStoppedPackages' { 0x00000010 }
        'IncludeStoppedPackages' { 0x00000020 }
        'GrantPersistableUriPermission' { 0x00000040 }
        'GrantPrefixUriPermission' { 0x00000080 }
        'DirectBootAuto' { 0x00000100 }
        'DebugTriagedMissing' { 0x00000100 }
        'IgnoreEphemeral' { 0x80000000 }
        'ActivityMatchExternal' { 0x00000800 }
        'ActivityNoHistory' { 0x40000000 }
        'ActivitySingleTop' { 0x20000000 }
        'ActivityNewTask' { 0x10000000 }
        'ActivityMultipleTask' { 0x08000000 }
        'ActivityClearTop' { 0x04000000 }
        'ActivityForwardResult' { 0x02000000 }
        'ActivityPreviousIsTop' { 0x01000000 }
        'ActivityExcludeFromRecents' { 0x00800000 }
        'ActivityBroughtToFront' { 0x00400000 }
        'ActivityResetTaskIfNeeded' { 0x00200000 }
        'ActivityLaunchedFromHistory' { 0x00100000 }
        'ActivityNewDocument' { 0x00080000 }
        'ActivityClearWhenTaskReset' { 0x00080000 }
        'ActivityNoUserAction' { 0x00040000 }
        'ActivityReorderToFront' { 0x00020000 }
        'ActivityNoAnimation' { 0x00010000 }
        'ActivityClearTask' { 0x00008000 }
        'ActivityTaskOnHome' { 0x00004000 }
        'ActivityRetainInRecents' { 0x00002000 }
        'ActivityLaunchAdjacent' { 0x00001000 }
        'ActivityRequireNonBrowser' { 0x00000400 }
        'ActivityRequireDefault' { 0x00000200 }
        'ReceiverRegisteredOnly' { 0x40000000 }
        'ReceiverReplacePending' { 0x20000000 }
        'ReceiverForeground' { 0x10000000 }
        'ReceiverNoAbort' { 0x08000000 }
        'ReceiverRegisteredOnlyBeforeBoot' { 0x04000000 }
        'ReceiverBootUpgrade' { 0x02000000 }
        'ReceiverIncludeBackground' { 0x01000000 }
        'ReceiverExcludeBackground' { 0x00800000 }
        'ReceiverFromShell' { 0x00400000 }
        'ReceiverVisibleToInstantApps' { 0x00200000 }
        'ReceiverOffload' { 0x80000000 }
        'ReceiverOffloadForeground' { 0x00000800 }
    }
}
