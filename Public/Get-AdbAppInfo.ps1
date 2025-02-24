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
                # For more information: https://developer.android.com/guide/topics/manifest/application-element
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package '$appId'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false

                $output = [PSCustomObject] @{
                    DeviceId      = $id
                    ApplicationId = $appId
                }

                $lineEnumerator = ConvertToLineEnumerator ($rawData.GetEnumerator())

                $lineEnumerator.MoveNextIgnoringBlank() > $null

                if ($lineEnumerator.Current.Contains('Activity Resolver Table:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'ActivityResolverTable' -Value ([PSCustomOBject] @{})
                    $lineEnumerator.MoveNextIgnoringBlank() > $null

                    if ($lineEnumerator.Current.Contains('  Schemes:')) {
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $output.ActivityResolverTable | Add-Member -MemberType NoteProperty -Name 'Schemes' -Value @()

                        ParseScheme -LineEnumerator $lineEnumerator -InputObject $output.ActivityResolverTable
                    }
                    if ($lineEnumerator.Current.Contains('Non-Data Actions:')) {
                        $output.ActivityResolverTable | Add-Member -MemberType NoteProperty -Name 'NonDataActions' -Value @()
                        $lineEnumerator.MoveNextIgnoringBlank() > $null

                        ParseNonDataAction -LineEnumerator $lineEnumerator -InputObject $output.ActivityResolverTable -ComponentType 'Activity'
                    }
                }
                if ($lineEnumerator.Current.Contains('Receiver Resolver Table:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'ReceiverResolverTable' -Value ([PSCustomOBject] @{})
                    $lineEnumerator.MoveNextIgnoringBlank() > $null

                    if ($lineEnumerator.Current.Contains('Non-Data Actions:')) {
                        $output.ReceiverResolverTable | Add-Member -MemberType NoteProperty -Name 'NonDataActions' -Value @()
                        $lineEnumerator.MoveNextIgnoringBlank() > $null

                        ParseNonDataAction -LineEnumerator $lineEnumerator -InputObject $output.ReceiverResolverTable -ComponentType 'Receiver'
                    }
                }
                if ($lineEnumerator.Current.Contains('Service Resolver Table:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'ServiceResolverTable' -Value ([PSCustomOBject] @{})
                    $lineEnumerator.MoveNextIgnoringBlank() > $null

                    if ($lineEnumerator.Current.Contains('Non-Data Actions:')) {
                        $output.ServiceResolverTable | Add-Member -MemberType NoteProperty -Name 'NonDataActions' -Value @()
                        $lineEnumerator.MoveNextIgnoringBlank() > $null

                        ParseNonDataAction -LineEnumerator $lineEnumerator -InputObject $output.ServiceResolverTable -ComponentType 'Service'
                    }
                }
                while ($lineEnumerator.Current.Contains('Permissions:')) {
                    if ($output.PSObject.Properties.Name -notcontains 'Permissions') {
                        $output | Add-Member -MemberType NoteProperty -Name 'Permissions' -Value @()
                    }

                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    while ($lineEnumerator.Current -match $script:PermissionPattern) {
                        $permissionMatches = $lineEnumerator.Current | Select-String -Pattern $script:PermissionPattern `
                        | Select-Object -ExpandProperty Matches -First 1

                        $permissionMatchGroups = $permissionMatches.Groups

                        $permission = [PSCustomObject]@{
                            Name = $permissionMatchGroups['permission'].Value
                            Hash = $permissionMatchGroups['permissionHash'].Value
                        }

                        $output.Permissions += $permission

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                    }
                }
                if ($lineEnumerator.Current.Contains('Registered ContentProviders:')) {
                    if ($output.PSObject.Properties.Name -notcontains 'RegisteredContentProviders') {
                        $output | Add-Member -MemberType NoteProperty -Name 'RegisteredContentProviders' -Value @()
                    }

                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    while ($lineEnumerator.Current -match $script:ProviderPattern) {
                        $providerMatches = $lineEnumerator.Current | Select-String -Pattern $script:ProviderPattern `
                        | Select-Object -ExpandProperty Matches -First 1

                        $providerMatchGroups = $providerMatches.Groups

                        $provider = [PSCustomObject]@{
                            Package            = $providerMatchGroups['package'].Value
                            ComponentClassName = $providerMatchGroups['componentClassName'].Value
                            Hash               = $providerMatchGroups['providerHash'].Value
                        }

                        $output.RegisteredContentProviders += $provider

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        if ($lineEnumerator.Current -notmatch '(?<package>[a-zA-Z0-9\.]+)\/(?<componentClassName>[a-zA-Z0-9\.\/_]+):') {
                            break
                        }
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                    }
                }
                if ($lineEnumerator.Current.Contains('ContentProvider Authorities:')) {
                    if ($output.PSObject.Properties.Name -notcontains 'ContentProviderAuthorities') {
                        $output | Add-Member -MemberType NoteProperty -Name 'ContentProviderAuthorities' -Value @()
                    }

                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    while ($lineEnumerator.Current -match $script:ProviderPattern) {
                        $providerMatches = $lineEnumerator.Current | Select-String -Pattern $script:ProviderPattern `
                        | Select-Object -ExpandProperty Matches -First 1

                        $providerMatchGroups = $providerMatches.Groups

                        $provider = [PSCustomObject]@{
                            Package            = $providerMatchGroups['package'].Value
                            ComponentClassName = $providerMatchGroups['componentClassName'].Value
                            Hash               = $providerMatchGroups['providerHash'].Value
                        }

                        $output.ContentProviderAuthorities += $provider

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        if ($lineEnumerator.Current -notmatch '\[(?<package>[a-zA-Z0-9\.\-]+)\]:') {
                            break
                        }
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                    }
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



$script:ComponentPattern = '(?<componentHash>[a-f0-9]+)\s(?<package>[a-zA-Z0-9\.]+)\/(?<componentClassName>[a-zA-Z0-9\.\/_]+)\sfilter\s(?<filterHash>[a-f0-9]+)'
$script:ActionPattern = '\s{6}([\w]+\.[\w\.\d_]+):'
$script:AttributePattern = '(?<attributeName>\w+)(:\s|=)(?<value>[^,^\s]+)'
$script:PermissionPattern = ' Permission \[(?<permission>[a-zA-Z0-9\._]+)\] \((?<permissionHash>[a-f0-9]+)\):'
$script:ProviderPattern = 'Provider{(?<providerHash>[a-f0-9]+) (?<package>[a-zA-Z0-9\.]+)\/(?<componentClassName>[a-zA-Z0-9\.\/_]+)}'



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

function ParseScheme {

    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )

    while ($LineEnumerator.Current -match "\s{6}\w+:") {
        $scheme = [PSCustomObject]@{
            Name = $LineEnumerator.Current.Trim().Replace(':', '')
        }

        $LineEnumerator.MoveNextIgnoringBlank() > $null

        ParseComponent -LineEnumerator $LineEnumerator -InputObject $scheme -ComponentType 'Activity'

        $InputObject.Schemes += $scheme
    }
}

function ParseNonDataAction {

    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject,

        [string] $ComponentType
    )

    while ($LineEnumerator.Current -match $script:ActionPattern) {
        $actionMatches = $LineEnumerator.Current | Select-String -Pattern $script:ActionPattern `
        | Select-Object -ExpandProperty Matches -First 1

        $actionMatchGroups = $actionMatches.Groups

        $actionName = $actionMatchGroups[1].Value

        $action = [PSCustomObject]@{
            Name = $actionName
        }

        $LineEnumerator.MoveNextIgnoringBlank() > $null

        ParseComponent -LineEnumerator $LineEnumerator -InputObject $action -ComponentType $ComponentType

        $InputObject.NonDataActions += $action
    }
}


function ParseComponent {

    [OutputType([PSCustomObject[]])]
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

    [OutputType([PSCustomObject[]])]
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
            $attributeValue = $_.Groups['value'].Value.Trim('"')
    
            if ($attributeName -in $properties.PSObject.Properties.Name) {
                if ($properties.$attributeName.Count -eq 1) {
                    $properties.$attributeName = @($properties.$attributeName)
                }
                $properties.$attributeName += $attributeValue
            }
            else {
                $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $attributeValue
            }

            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
    }
}
