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
                    $output | Add-Member -MemberType NoteProperty -Name 'PreferredActivitiesUser' -Value @()

                    while ($lineEnumerator.Current -match 'Preferred Activities User \d+:') {
                        $userIndex = $lineEnumerator.Current | Select-String -Pattern 'Preferred Activities User (?<userIndex>\d+):' `
                        | Select-Object -ExpandProperty Matches -First 1 `
                        | ForEach-Object { $_.Groups['userIndex'].Value }

                        $userActivity = [PSCustomObject]@{
                            UserIndex = $userIndex
                        }
                        ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'Table' -InputObject $userActivity -ComponentType 'Activity'

                        $output.PreferredActivitiesUser += $userActivity
                    }
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

                    $lineEnumerator.MoveNextIgnoringBlank() > $null     
                }
                if ($lineEnumerator.Current.Contains('Packages:')) {
                    ParsePackages -LineEnumerator $lineEnumerator -InputObject $output
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
$script:PackageHeaderPattern = '\s{2}Package \[(?<package>[a-zA-Z0-9\.]+)\] \((?<packageHash>[a-f0-9]+)\):'

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

    while ($LineEnumerator.Current -match $script:AttributePattern -or ($LineEnumerator.Current.EndsWith(':') -and $LineEnumerator.Current.StartsWith('          '))) {
        if ($InputObject.PSObject.Properties.Name -notcontains 'Properties') {
            $properties = [PSCustomObject]@{}
            $InputObject | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $properties
        }

        if ($LineEnumerator.Current.EndsWith(':')) {
            $attributeName = $LineEnumerator.Current.Trim().Replace(':', '')
            if ($attributeName.Contains(' ')) {
                $attributeName = ConvertToCamelCase $attributeName
            }
            $LineEnumerator.MoveNextIgnoringBlank() > $null

            $values = @()

            while ($LineEnumerator.Current -notmatch $script:AttributePattern) {
                $values += $LineEnumerator.Current.Trim()
                $LineEnumerator.MoveNextIgnoringBlank() > $null
            }

            $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $values
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

function ParsePackages {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )

    $InputObject | Add-Member -MemberType NoteProperty -Name 'Packages' -Value @()

    $LineEnumerator.MoveNextIgnoringBlank() > $null
    while ($LineEnumerator.Current -match $script:PackageHeaderPattern) {
        $packageMatches = $LineEnumerator.Current | Select-String -Pattern $script:PackageHeaderPattern `
        | Select-Object -ExpandProperty Matches -First 1

        $package = [PSCustomObject]@{
            Name = $packageMatches.Groups['package'].Value
            Hash = $packageMatches.Groups['packageHash'].Value
        }

        $InputObject.Packages += $package

        $properties = [PSCustomObject]@{}
        $package | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $properties


        $LineEnumerator.MoveNextIgnoringBlank() > $null
        while ($LineEnumerator.Current.EndsWith(':') -or $LineEnumerator.Current.Contains('=')) {
            if ($LineEnumerator.Current.StartsWith('    User 0:')) {
                # We don't plan to parse beyond User 0 yet
                break
            }

            if ($LineEnumerator.Current.Contains('versionCode') -or $LineEnumerator.Current.Contains('userId') -or $LineEnumerator.Current.Contains('permissionsFixed')) {
                $LineEnumerator.Current | Select-String -Pattern '(?<attributeName>\w+)=(?<attributeValue>(\d+|\w+))' -AllMatches `
                | Select-Object -ExpandProperty Matches `
                | ForEach-Object {
                    $attributeName = $_.Groups['attributeName'].Value
                    $attributeValue = $_.Groups['attributeValue'].Value

                    $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $attributeValue
                }
                $LineEnumerator.MoveNextIgnoringBlank() > $null
                continue
            }
            
            if ($LineEnumerator.Current.EndsWith(':')) {
                $attributeName = $LineEnumerator.Current.Trim().Replace(':', '')
                if ($attributeName.Contains(' ')) {
                    $attributeName = ConvertToCamelCase $attributeName
                }
                $LineEnumerator.MoveNextIgnoringBlank() > $null

                $values = @()

                while ($LineEnumerator.Current.StartsWith('      ')) {
                    $values += $LineEnumerator.Current.Trim()
                    $LineEnumerator.MoveNextIgnoringBlank() > $null
                }

                $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $values
            }
            elseif ($LineEnumerator.Current.Contains('=')) {
                $attributeNameSb = [System.Text.StringBuilder]::new()
                $valueSb = [System.Text.StringBuilder]::new()
                $equalsCharFound = $false
                foreach ($char in $LineEnumerator.Current.GetEnumerator()) {
                    if ($char -eq '=' -and -not $equalsCharFound) {
                        $equalsCharFound = $true
                        continue
                    }
                    if ($equalsCharFound) {
                        $valueSb.Append($char) > $null
                        continue
                    }
                    $attributeNameSb.Append($char) > $null
                }
                $attributeName = $attributeNameSb.ToString().Trim()
                $value = $valueSb.ToString().Trim()

                # [ HAS_CODE ALLOW_CLEAR_USER_DATA ]
                if ($value -match '\[\s*(\w+(?:\s+\w+)*)\s*\]') {
                    $value = $value.Trim('[', ']', ' ') -split '\s+'
                }
                # [base, chrome, config.en, config.es, config.fr]
                elseif ($value -match '\[\s*([\w.-]+(?:\s*,\s*[\w.-]+)*)\s*\]') {
                    $value = $value.Trim('[', ']', ' ') -split '\s*,\s*'
                }

                $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $value

                $LineEnumerator.MoveNextIgnoringBlank() > $null
            }
        }

        $LineEnumerator.MoveNextIgnoringBlank() > $null
    }
}


function ConvertToCamelCase {

    param (
        [string] $InputObject
    )

    $words = $InputObject -split '\s+'
    
    if ($words.Count -gt 0) {
        $camelCase = $words[0].ToLower()
        
        foreach ($word in $words[1..($words.Count - 1)]) {
            $camelCase += $word.Substring(0, 1).ToUpper() + $word.Substring(1).ToLower()
        }
        return $camelCase
    }
    
    return ""
}
