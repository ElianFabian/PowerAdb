function Get-AdbAppInfo {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false

                $output = [PSCustomObject] @{
                    DeviceId      = $id
                    ApplicationId = $appId
                }

                $lineEnumerator = ConvertToLineEnumerator ($rawData.GetEnumerator())

                $lineEnumerator.MoveNextIgnoringBlank() > $null

                if ($lineEnumerator.Current.Contains('Activity Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ActivityResolverTable' -InputObject $output -ComponentType 'Activity'
                }
                if ($lineEnumerator.Current.Contains('Receiver Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ReceiverResolverTable' -InputObject $output -ComponentType 'Receiver'
                }
                if ($lineEnumerator.Current.Contains('Service Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ServiceResolverTable' -InputObject $output -ComponentType 'Service'
                }
                if ($lineEnumerator.Current -match 'Preferred Activities User \d+:') {
                    $userIndex = $lineEnumerator.Current | Select-String -Pattern 'Preferred Activities User (?<userIndex>\d+):' `
                    | Select-Object -ExpandProperty Matches -First 1 `
                    | ForEach-Object { $_.Groups['userIndex'].Value }

                    $output | Add-Member -MemberType NoteProperty -Name 'PreferredActivitiesUser' -Value @()

                    $userActivity = [PSCustomObject]@{
                        UserIndex = $userIndex
                    }

                    while ($lineEnumerator.Current -match 'Preferred Activities User \d+:') {
                        ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'Table' -InputObject $userActivity -ComponentType 'Activity'
                    }

                    $output.PreferredActivitiesUser += $userActivity
                }
                while ($lineEnumerator.Current.Contains('Permissions:')) {
                    ParsePermissions -LineEnumerator $lineEnumerator -InputObject $output
                }
                if ($lineEnumerator.Current.Contains('Registered ContentProviders:')) {
                    ParseRegisteredContentProvider -LineEnumerator $lineEnumerator -InputObject $output
                }
                if ($lineEnumerator.Current.Contains('ContentProvider Authorities:')) {
                    ParseContentProviderAuthorities -LineEnumerator $lineEnumerator -InputObject $output
                }
                if ($lineEnumerator.Current.Contains('Key Set Manager:')) {
                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    $lineEnumerator.MoveNextIgnoringBlank() > $null

                    $signingKeySetsMatches = $lineEnumerator.Current | Select-String -Pattern 'Signing KeySets: (?<keySets>\d+)'
                    $output | Add-Member -MemberType NoteProperty -Name 'SigningKeySets' -Value ([int] $signingKeySetsMatches.Matches[0].Groups['keySets'].Value)
                }

                $output
            }
        }
    }
}



$script:ComponentPattern = '(?<componentHash>[a-f0-9]+)\s(?<package>[a-zA-Z0-9\.]+)\/(?<componentClassName>[a-zA-Z0-9\.\/_$]+)(\sfilter\s(?<filterHash>[a-f0-9]+))?'
$script:ActionPattern = '\s{6}([\w\.\d_]+):'
$script:AttributePattern = '(?<attributeName>\w+)(:\s|=)(?<attributeValue>[^,^\n\r]+)'
$script:PermissionPattern = ' Permission \[(?<permission>[a-zA-Z0-9\._]+)\] \((?<permissionHash>[a-f0-9]+)\):'
$script:PermissionAttributePattern = '(?<attributeName>\w+)=(?<attributeValue>[a-zA-Z]+{.+}|[^\s]+)'
$script:ProviderPattern = 'Provider{(?<providerHash>[a-f0-9]+) (?<package>[a-zA-Z0-9\.]+)(\/(?<componentClassName>[a-zA-Z0-9\.\/_]+))?}'
$script:FullMimeTypeHeaderPattern = '\s{6}[a-zA-Z*\d+_.]+\/[a-zA-Z*\d+_.-]+:'
$script:BaseMimeTypeHeaderPattern = '\s{6}[a-zA-Z*\d+_.]+:'
$script:WildMimeTypeHeaderPattern = '\s{6}[a-zA-Z*\d+_.]+:'
$script:SchemeHeaderPattern = '\s{6}[\w.]*:'



function ConvertToLineEnumerator {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IEnumerator] $InputObject
    )

    process {
        $lineEnumerator = [PSCustomObject]@{
            enumerator = $InputObject
        }

        $lineEnumerator | Add-Member -MemberType ScriptMethod -Name MoveNextIgnoringBlank -Value {
            while ($this.enumerator.MoveNext()) {
                if ([string]::IsNullOrWhiteSpace($this.enumerator.Current)) {
                    continue
                }
                return $true
            }
            return $false
        }
        $lineEnumerator | Add-Member -MemberType ScriptProperty -Name Current -Value {
            $this.enumerator.Current
        }

        return $lineEnumerator
    }
}

function ParseResolverTable {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [string] $ResolverTableName,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject,

        [Parameter(Mandatory)]
        [string] $ComponentType
    )

    $InputObject | Add-Member -MemberType NoteProperty -Name $ResolverTableName -Value ([PSCustomOBject] @{})
    $LineEnumerator.MoveNextIgnoringBlank() > $null

    if ($LineEnumerator.Current.Contains('  Full MIME Types:')) {
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'FullMimeTypes' -Value @()

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'FullMimeTypes' -ComponentType $ComponentType -Pattern $script:FullMimeTypeHeaderPattern
    }
    if ($LineEnumerator.Current.Contains('  Base MIME Types:')) {
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'BaseMimeTypes' -Value @()

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'BaseMimeTypes' -ComponentType $ComponentType -Pattern $script:BaseMimeTypeHeaderPattern
    }
    if ($LineEnumerator.Current.Contains('  Wild MIME Types:')) {
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'WildMimeTypes' -Value @()

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'WildMimeTypes' -ComponentType $ComponentType -Pattern $script:WildMimeTypeHeaderPattern
    }
    if ($LineEnumerator.Current.Contains('  Schemes:')) {
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'Schemes' -Value @()

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'Schemes' -ComponentType $ComponentType -Pattern $script:SchemeHeaderPattern
    }
    if ($LineEnumerator.Current.Contains('  Non-Data Actions:')) {
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'NonDataActions' -Value @()
        $LineEnumerator.MoveNextIgnoringBlank() > $null

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'NonDataActions' -ComponentType $ComponentType -Pattern $script:ActionPattern
    }
    if ($LineEnumerator.Current.Contains('  MIME Typed Actions:')) {
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'MimeTypedActions' -Value @()
        $LineEnumerator.MoveNextIgnoringBlank() > $null

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'MimeTypedActions' -ComponentType $ComponentType -Pattern $script:ActionPattern
    }
}

function ParseComponentContainer {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject,

        [string] $Name,

        [Parameter(Mandatory)]
        [string] $ComponentType,

        [Parameter(Mandatory)]
        [string] $Pattern
    )

    while ($LineEnumerator.Current -match $Pattern) {
        $container = [PSCustomObject]@{
            Name = $LineEnumerator.Current.Trim().Replace(':', '')
        }

        $LineEnumerator.MoveNextIgnoringBlank() > $null

        ParseComponent -LineEnumerator $LineEnumerator -InputObject $container -ComponentType $ComponentType

        $InputObject.$Name += $container
    }
}

function ParsePermissions {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )

    if ($InputObject.PSObject.Properties.Name -notcontains 'Permissions') {
        $InputObject | Add-Member -MemberType NoteProperty -Name 'Permissions' -Value @()
    }

    $LineEnumerator.MoveNextIgnoringBlank() > $null
    while ($LineEnumerator.Current -match $script:PermissionPattern) {
        $permissionMatches = $LineEnumerator.Current | Select-String -Pattern $script:PermissionPattern `
        | Select-Object -ExpandProperty Matches -First 1

        $permissionMatchGroups = $permissionMatches.Groups

        $permission = [PSCustomObject]@{
            Name = $permissionMatchGroups['permission'].Value
            Hash = $permissionMatchGroups['permissionHash'].Value
        }

        $properties = [PSCustomObject]@{}

        $LineEnumerator.MoveNextIgnoringBlank() > $null
        while ($LineEnumerator.Current -match $script:PermissionAttributePattern) {
            $LineEnumerator.Current | Select-String -Pattern $script:PermissionAttributePattern -AllMatches `
            | Select-Object -ExpandProperty Matches `
            | ForEach-Object {
                $attributeName = $_.Groups['attributeName'].Value
                $attributeValue = $_.Groups['attributeValue'].Value

                if ($attributeName -in $properties.PSObject.Properties.Name) {
                    if ($properties.$attributeName.Count -eq 1) {
                        $properties.$attributeName = @($properties.$attributeName)
                    }
                    $properties.$attributeName += $attributeValue
                }
                else {
                    $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $attributeValue
                }
            }

            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }

        $permission | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $properties

        $InputObject.Permissions += $permission
    }
}

function ParseRegisteredContentProvider {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )


    if ($InputObject.PSObject.Properties.Name -notcontains 'RegisteredContentProviders') {
        $InputObject | Add-Member -MemberType NoteProperty -Name 'RegisteredContentProviders' -Value @()
    }

    $LineEnumerator.MoveNextIgnoringBlank() > $null
    $LineEnumerator.MoveNextIgnoringBlank() > $null
    while ($LineEnumerator.Current -match $script:ProviderPattern) {
        $providerMatches = $LineEnumerator.Current | Select-String -Pattern $script:ProviderPattern `
        | Select-Object -ExpandProperty Matches -First 1

        $providerMatchGroups = $providerMatches.Groups

        $provider = [PSCustomObject]@{
            Package            = $providerMatchGroups['package'].Value
            ComponentClassName = $providerMatchGroups['componentClassName'].Value
            Hash               = $providerMatchGroups['providerHash'].Value
        }

        $InputObject.RegisteredContentProviders += $provider

        $LineEnumerator.MoveNextIgnoringBlank() > $null
        if ($LineEnumerator.Current -notmatch '(?<package>[a-zA-Z0-9\.]+)\/(?<componentClassName>[a-zA-Z0-9\.\/_]+):') {
            break
        }
        $LineEnumerator.MoveNextIgnoringBlank() > $null
    }
}

function ParseContentProviderAuthorities {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )


    if ($InputObject.PSObject.Properties.Name -notcontains 'ContentProviderAuthorities') {
        $InputObject | Add-Member -MemberType NoteProperty -Name 'ContentProviderAuthorities' -Value @()
    }

    $pattern = '\[(?<providerName>[a-zA-Z0-9\.\-_]+)\]:'
    $LineEnumerator.MoveNextIgnoringBlank() > $null
    while ($LineEnumerator.Current -match $pattern) {
        $providerName = $LineEnumerator.Current | Select-String -Pattern $pattern `
        | Select-Object -ExpandProperty Matches -First 1 `
        | ForEach-Object { $_.Groups['providerName'].Value }
        
        $LineEnumerator.MoveNextIgnoringBlank() > $null

        $providerMatches = $LineEnumerator.Current | Select-String -Pattern $script:ProviderPattern `
        | Select-Object -ExpandProperty Matches -First 1

        $providerMatchGroups = $providerMatches.Groups

        $provider = [PSCustomObject]@{
            Name               = $providerName
            Package            = $providerMatchGroups['package'].Value
            ComponentClassName = $providerMatchGroups['componentClassName'].Value
            Hash               = $providerMatchGroups['providerHash'].Value
        }

        $InputObject.ContentProviderAuthorities += $provider

        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        if ($LineEnumerator.Current -notmatch $pattern) {
            break
        }
    }
}

function ParseComponent {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject,

        [string] $ComponentType
    )

    while ($LineEnumerator.Current -match $script:ComponentPattern) {
        $rawComponentData = $lineEnumerator.Current

        $componentMatches = $rawComponentData | Select-String -Pattern $script:ComponentPattern `
        | Select-Object -ExpandProperty Matches -First 1

        $componentMatchGroups = $componentMatches.Groups

        $componentInfo = [PSCustomObject] @{
            ComponentHash      = $componentMatchGroups['componentHash'].Value
            Package            = $componentMatchGroups['package'].Value
            ComponentClassName = $componentMatchGroups['componentClassName'].Value
            FilterHash         = $componentMatchGroups['filterHash'].Value
            Type               = $ComponentType
        }

        if ($InputObject.PSObject.Properties.Name -contains 'Components') {
            $InputObject.Components += $componentInfo
        }
        else {
            $InputObject | Add-Member -MemberType NoteProperty -Name 'Components' -Value @($componentInfo)
        }

        $lineEnumerator.MoveNextIgnoringBlank() > $null

        ParseComponentAttribute -LineEnumerator $lineEnumerator -InputObject $componentInfo
    }
}

function ParseComponentAttribute {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )

    while ($LineEnumerator.Current -match $script:AttributePattern) {
        if ($InputObject.PSObject.Properties.Name -notcontains 'Properties') {
            $properties = [PSCustomObject]@{}
            $InputObject | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $properties
        }

        $LineEnumerator.Current | Select-String -Pattern $script:AttributePattern -AllMatches `
        | Select-Object -ExpandProperty Matches `
        | ForEach-Object {
            $attributeName = $_.Groups['attributeName'].Value
            $attributeValue = $_.Groups['attributeValue'].Value.Trim('"')
    
            if ($attributeName -in $properties.PSObject.Properties.Name) {
                if ($properties.$attributeName.Count -eq 1) {
                    $properties.$attributeName = @($properties.$attributeName)
                }
                $properties.$attributeName += $attributeValue
            }
            else {
                $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $attributeValue
            }
        }


        $LineEnumerator.MoveNextIgnoringBlank() > $null
    }
}
