function Get-AdbPackageInfo {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [string[]] $PackageName
    )

    begin {
        if (-not $PackageName) {
            $noPackage = $true
            $PackageName = @('*') # Arbitrary value to ensure we enter the loop exactly once
        }
    }

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                $packageArg = if ($noPackage) {
                    ''
                }
                else {
                    " '$package'"
                }
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys package$packageArg" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false

                $output = [PSCustomObject] @{
                    DeviceId    = $id
                }

                if (-not $noPackage) {
                    $output | Add-Member -MemberType NoteProperty -Name 'PackageName' -Value $package
                }

                $lineEnumerator = ConvertToLineEnumerator ($rawData.GetEnumerator())

                $lineEnumerator.MoveNextIgnoringBlank() > $null

                SkipMiscellaneous -LineEnumerator $lineEnumerator

                if ($LineEnumerator.Current.Contains('Libraries:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'Libraries' -Value @()
                    do {
                        $LineEnumerator.MoveNextIgnoringBlank() > $null
                        $libraryMatch = $script:LibraryRegex.Match($LineEnumerator.Current)
                        if ($libraryMatch.Success) {
                            $library = [PSCustomObject]@{
                                PackageName = $libraryMatch.Groups['libraryName'].Value
                                Type        = $libraryMatch.Groups['libraryType'].Value
                                Path        = $libraryMatch.Groups['libraryPath'].Value
                            }
                            $output.Libraries += $library
                        }
                    }
                    while ($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':')
                }
                if ($LineEnumerator.Current.Contains('Features:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'Features' -Value @()
                    do {
                        $LineEnumerator.MoveNextIgnoringBlank() > $null
                        $output.Features += $LineEnumerator.Current.Trim()
                    }
                    while ($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':')
                }
                if ($lineEnumerator.Current.Contains('Activity Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ActivityResolverTable' -InputObject $output -ComponentType 'Activity'
                }
                if ($lineEnumerator.Current.Contains('Receiver Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ReceiverResolverTable' -InputObject $output -ComponentType 'Receiver'
                }
                if ($lineEnumerator.Current.Contains('Service Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ServiceResolverTable' -InputObject $output -ComponentType 'Service'
                }
                if ($lineEnumerator.Current.Contains('Provider Resolver Table:')) {
                    ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'ProviderResolverTable' -InputObject $output -ComponentType 'Provider'
                }
                if ($lineEnumerator.Current -match 'Preferred Activities User \d+:') {
                    $output | Add-Member -MemberType NoteProperty -Name 'PreferredActivities' -Value @()

                    while ($lineEnumerator.Current -match 'Preferred Activities User (?<userId>\d+):') {
                        $userId = $Matches['userId']

                        $userActivity = [PSCustomObject]@{
                            UserId = $userId
                        }
                        ParseResolverTable -LineEnumerator $lineEnumerator -ResolverTableName 'Table' -InputObject $userActivity -ComponentType 'Activity'

                        $output.PreferredActivities += $userActivity
                    }
                }
                if ($lineEnumerator.Current.StartsWith('App verification status:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'AppVerificationStatus' -Value @()

                    $lineEnumerator.MoveNextIgnoringBlank() > $null

                    while ($lineEnumerator.Current[0] -ceq ' ' -and $LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':') {
                        $package = $lineEnumerator.Current.Trim().SubString('Package: '.Length)

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $domains = $lineEnumerator.Current.Trim().SubString('Domains: '.Length) -split ' '

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $status = $lineEnumerator.Current.Trim().SubString('Status: '.Length)

                        $linkage = [PSCustomObject]@{
                            Package = $package
                            Domains = $domains
                            Status  = $status
                        }

                        $output.AppVerificationStatus += $linkage

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                    }
                }
                while ($lineEnumerator.Current -match 'App linkages for user (?<userId>\d+):') {
                    if ($output.PSObject.Properties.Name -notcontains 'AppLinkagesForUser') {
                        $output | Add-Member -MemberType NoteProperty -Name 'AppLinkagesForUser' -Value @()
                    }

                    $user = [PSCUstomObject]@{
                        UserId      = [uint32] $Matches['userId']
                        AppLinkages = @()
                    }

                    $output.AppLinkagesForUser += $user

                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    while ($lineEnumerator.Current[0] -ceq ' ' -and $LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':') {
                        #  Package: com.google.android.calendar
                        $package = $lineEnumerator.Current.Trim().SubString('Package: '.Length)

                        #  Domains: www.google.com calendar.google.com client-side-encryption.google.com krahsc.google.com
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $domains = $lineEnumerator.Current.Trim().SubString('Domains: '.Length) -split ' '

                        #  Status:  always : 200000005
                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $status = $lineEnumerator.Current.Trim().SubString('Status: '.Length)

                        $linkage = [PSCustomObject]@{
                            Package = $package
                            Domains = $domains
                            Status  = $status
                        }

                        $user.AppLinkages += $linkage

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                    }
                }
                while ($lineEnumerator.Current.StartsWith('Permissions:')) {
                    ParsePermissions -LineEnumerator $lineEnumerator -InputObject $output
                }
                if ($lineEnumerator.Current.StartsWith('AppOp Permissions:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'AppOpPermissions' -Value @()

                    $lineEnumerator.MoveNextIgnoringBlank() > $null

                    while ($lineEnumerator.Current -match "AppOp Permission (?<permissionName>$script:PackagePattern):") {
                        $permissionName = $Matches['permissionName']

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        $permission = [PSCustomObject]@{
                            PermissionName = $permissionName
                            Packages       = @()
                        }
                        while ($lineEnumerator.Current[0] -ceq ' ' -and $lineEnumerator.Current[$lineEnumerator.Current.Length - 1] -cne ':') {
                            $packageName = $lineEnumerator.Current.Trim()
                            $permission.Packages += $packageName

                            $lineEnumerator.MoveNextIgnoringBlank() > $null
                        }

                        $output.AppOpPermissions += $permission
                    }
                }
                if ($lineEnumerator.Current.Contains('Registered ContentProviders:')) {
                    ParseRegisteredContentProvider -LineEnumerator $lineEnumerator -InputObject $output
                }
                if ($lineEnumerator.Current.Contains('ContentProvider Authorities:')) {
                    ParseContentProviderAuthorities -LineEnumerator $lineEnumerator -InputObject $output
                }
                if ($lineEnumerator.Current.Contains('Key Set Manager:')) {
                    $output | Add-Member -MemberType NoteProperty -Name 'KeySetManager' -Value @()

                    $lineEnumerator.MoveNextIgnoringBlank() > $null
                    while ($lineEnumerator.Current[$lineEnumerator.Current.Length - 1] -ceq ']') {

                        $package = $lineEnumerator.Current.Trim(' ', '[', ']')

                        $packageObject = [PSCustomObject]@{
                            PackageName = $package
                            KeySets     = [PSCustomObject]@{}
                        }

                        $lineEnumerator.MoveNextIgnoringBlank() > $null
                        while ($lineEnumerator.Current -match '(?<name>\w+ \w+): (?<value>.+)') {
                            $rawName = $Matches['name']
                            $rawValue = $Matches['value']

                            $name = ConvertToPascalCase $rawName

                            if ($rawValue.Contains('=')) {
                                $keyValuePairs = $rawValue -split ',' | ForEach-Object { $_.Trim() }

                                $object = [PSCustomObject]@{}

                                $keyValuePairs | ForEach-Object {
                                    $keyValuePair = $_ -split '='
                                    $keyName = $keyValuePair[0].Trim()
                                    $keyValue = [int] $keyValuePair[1].Trim()

                                    $object | Add-Member -MemberType NoteProperty -Name $keyName -Value $keyValue
                                }

                                $packageObject.KeySets | Add-Member -MemberType NoteProperty -Name $name -Value $object
                            }
                            else {
                                if ($rawValue.Contains(',')) {
                                    $value = $rawValue -split ',' | ForEach-Object { [int] $_.Trim() }

                                    $packageObject.KeySets | Add-Member -MemberType NoteProperty -Name $name -Value $value
                                }
                                else {
                                    $packageObject.KeySets | Add-Member -MemberType NoteProperty -Name $name -Value ([int] $rawValue)
                                }
                            }

                            $lineEnumerator.MoveNextIgnoringBlank() > $null
                        }

                        $output.KeySetManager += $packageObject
                    }
                }
                if ($lineEnumerator.Current.Contains('Packages:')) {
                    ParsePackages -LineEnumerator $lineEnumerator -InputObject $output
                }

                $output
            }
        }
    }
}



$script:PackagePattern = '[a-zA-Z0-9\._]+'
$HashPattern = '[a-f0-9]+'
$ComponentClassNamePattern = '[a-zA-Z0-9\.\/_$]+'
$MimeTypeHeaderPattern = '\s{6}[a-zA-Z*\d+_.\-/]+:'

$script:ComponentPattern = (
    "(?<componentHash>$HashPattern)\s(?<package>$PackagePattern)\/(?<componentClassName>$ComponentClassNamePattern)(\sfilter\s(?<filterHash>$HashPattern))?"
)
$script:ComponentRegex = [regex]::new(
    $script:ComponentPattern
)
$script:ActionPattern = (
    '\s{6}([\w\.\d_\s\-]+):'
)
$script:AttributePattern = (
    '(?<attributeName>\w+)(:\s|=)(?<attributeValue>[^,^\n\r]+)'
)
$script:AttributeRegex = [regex]::new(
    $script:AttributePattern
)
$script:GroupAttributePattern = (
    '(?<attributeName>\w+)(:\s|=)(?<attributeValue>[^,^\s]+)'
)
$script:GroupAttributeRegex = [regex]::new(
    $script:GroupAttributePattern
)
$script:PermissionPattern = (
    " Permission \[(?<permission>$PackagePattern)\] \((?<permissionHash>$HashPattern)\):"
)
$script:PermissionRegex = [regex]::new(
    $script:PermissionPattern
)
$script:PermissionAttributePattern = (
    '(?<attributeName>\w+)=(?<attributeValue>[a-zA-Z]+{.+}|[^\s]+)'
)
$script:PermissionAttributeRegex = [regex]::new(
    $script:PermissionAttributePattern
)
$script:ProviderHeaderPattern = (
    "(?<package>$PackagePattern)\/(?<componentClassName>$ComponentClassNamePattern):"
)
$script:ContentProviderAuthoritiesHeaderPattern = (
    '\[(?<providerName>[a-zA-Z0-9\.\-_:]+)\]:'
)
$script:ContentProviderAuthoritiesHeaderRegex = [regex]::new(
    $script:ContentProviderAuthoritiesHeaderPattern
)
$script:ProviderPattern = (
    "Provider{(?<providerHash>$HashPattern) (?<package>$PackagePattern)(\/(?<componentClassName>$ComponentClassNamePattern))?}"
)
$script:ProviderRegex = [regex]::new(
    $script:ProviderPattern
)
$script:FullMimeTypeHeaderPattern = (
    $script:MimeTypeHeaderPattern
)
$script:BaseMimeTypeHeaderPattern = (
    $script:MimeTypeHeaderPattern
)
$script:WildMimeTypeHeaderPattern = (
    $script:MimeTypeHeaderPattern
)
$script:SchemeHeaderPattern = (
    '\s{6}[\w..\-+]*:'
)
$script:PackageHeaderPattern = (
    "\s{2}Package \[(?<package>$PackagePattern)\] \((?<packageHash>$HashPattern)\):"
)
$script:PackageHeaderRegex = [regex]::new(
    $script:PackageHeaderPattern
)
$script:PackageKeyValuePairRegex = [regex]::new(
    '(?<attributeName>\w+)=(?<attributeValue>(\d+|\w+))'
)
$script:LibraryRegex = [regex]::new(
    '\s+(?<libraryName>[\w\.]+)\s+->\s+\((?<libraryType>[\w\d_]+)\)\s(?<libraryPath>.+)'
)

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

function SkipMiscellaneous {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator
    )

    # TODO: Parse this correctly
    # For now we just skip them

    # Database versions:
    #     Internal:
    #         sdkVersion=30 databaseVersion=3
    #         fingerprint=realme/RMX2001EEA/RMX2001L1:11/RP1A.200720.011/1647528410735:user/release-keys
    #     External:
    #         sdkVersion=29 databaseVersion=3
    #         fingerprint=realme/RMX2001EEA/RMX2001L1:10/QP1A.190711.020/1591587271:user/release-keys

    # Verifiers:
    #   Required: com.android.vending (uid=10147)

    # Intent Filter Verifier:
    #   Using: com.google.android.gms (uid=10143)

    if ($LineEnumerator.Current.Contains('Database versions:')) {
        do {
            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
        while ($LineEnumerator.Current[0] -ceq ' ' -or $LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':')
    }
    if ($LineEnumerator.Current.Contains('Verifiers:')) {
        do {
            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
        while ($LineEnumerator.Current[0] -ceq ' ' -or $LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':')
    }
    if ($LineEnumerator.Current.Contains('Intent Filter Verifier:')) {
        do {
            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
        while ($LineEnumerator.Current[0] -ceq ' ' -or $LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':')
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
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'NonDataActions' -Value @()

        ParseComponentContainer -LineEnumerator $LineEnumerator -InputObject $InputObject.$ResolverTableName -Name 'NonDataActions' -ComponentType $ComponentType -Pattern $script:ActionPattern
    }
    if ($LineEnumerator.Current.Contains('  MIME Typed Actions:')) {
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $InputObject.$ResolverTableName | Add-Member -MemberType NoteProperty -Name 'MimeTypedActions' -Value @()

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
        $permission = [PSCustomObject]@{
            Name = $Matches['permission']
            Hash = $Matches['permissionHash']
        }

        $properties = [PSCustomObject]@{}

        $LineEnumerator.MoveNextIgnoringBlank() > $null
        while ($LineEnumerator.Current -match $script:PermissionAttributePattern) {
            $script:PermissionAttributeRegex.Matches($LineEnumerator.Current) `
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
        $provider = [PSCustomObject]@{
            Package            = $Matches['package']
            ComponentClassName = $Matches['componentClassName']
            Hash               = $Matches['providerHash']
        }

        $InputObject.RegisteredContentProviders += $provider

        $LineEnumerator.MoveNextIgnoringBlank() > $null
        if ($LineEnumerator.Current -notmatch $script:ProviderHeaderPattern) {
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

    $LineEnumerator.MoveNextIgnoringBlank() > $null
    while ($LineEnumerator.Current -match $script:ContentProviderAuthoritiesHeaderPattern) {
        $providerName = $Matches['providerName']

        $LineEnumerator.MoveNextIgnoringBlank() > $null

        $providerMatchGroups = $script:ProviderRegex.Match($LineEnumerator.Current).Groups

        $provider = [PSCustomObject]@{
            Name               = $providerName
            Package            = $providerMatchGroups['package'].Value
            ComponentClassName = $providerMatchGroups['componentClassName'].Value
            Hash               = $providerMatchGroups['providerHash'].Value
        }

        $InputObject.ContentProviderAuthorities += $provider

        $LineEnumerator.MoveNextIgnoringBlank() > $null
        $LineEnumerator.MoveNextIgnoringBlank() > $null
        if ($LineEnumerator.Current -notmatch $script:ContentProviderAuthoritiesHeaderPattern) {
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
        $componentInfo = [PSCustomObject] @{
            ComponentHash      = $Matches['componentHash']
            Package            = $Matches['package']
            ComponentClassName = $Matches['componentClassName']
            FilterHash         = $Matches['filterHash']
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

    while (($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -ceq ':' -and $LineEnumerator.Current.StartsWith('          ')) -or $LineEnumerator.Current -match $script:AttributePattern) {
        if ($InputObject.PSObject.Properties.Name -notcontains 'Properties') {
            $properties = [PSCustomObject]@{}
            $InputObject | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $properties
        }

        if ($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -ceq ':') {
            $attributeName = $LineEnumerator.Current.Trim().Replace(':', '')
            if ($attributeName.Contains(' ')) {
                $attributeName = ConvertToCamelCase $attributeName
            }
            $LineEnumerator.MoveNextIgnoringBlank() > $null

            $values = @()

            while ($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':' -and $LineEnumerator.Current -notmatch $script:AttributePattern) {
                $values += $LineEnumerator.Current.Trim()
                $LineEnumerator.MoveNextIgnoringBlank() > $null
            }

            $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $values
        }

        $LineEnumerator.Current | Select-String -Pattern $script:AttributePattern -AllMatches `
        | Select-Object -ExpandProperty Matches `
        | ForEach-Object {
            $attributeName = $_.Groups['attributeName'].Value
            if ($attributeName.Contains(' ')) {
                $attributeName = ConvertToCamelCase $attributeName
            }
            $attributeValue = $_.Groups['attributeValue'].Value.Trim('"')

            # [ HAS_CODE ALLOW_CLEAR_USER_DATA ]
            if ($attributeValue -match '^\[\s*(\w+(?:\s+\w+)*)\s*\]$') {
                $attributeValue = $attributeValue.Trim('[', ']', ' ') -split '\s+'
            }
            # [base, chrome, config.en, config.es, config.fr]
            elseif ($attributeValue -match '^\[\s*(.+(?:\s*,\s*[\w.-]+)*)\s*\]$') {
                $attributeValue = $attributeValue.Trim('[', ']', ' ') -split '\s*,\s*'
            }
            elseif ($attributeValue -eq '[]') {
                $attributeValue = @()
            }

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


# SEE-LATER: The logic for parsing attributes is kind of duplicated in ParseComponentAttribute and ParsePermissions

function ParsePackages {

    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $LineEnumerator,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )

    $InputObject | Add-Member -MemberType NoteProperty -Name 'Packages' -Value @()

    $LineEnumerator.MoveNextIgnoringBlank() > $null
    :outer while ($LineEnumerator.Current -match $script:PackageHeaderPattern) {
        $package = [PSCustomObject]@{
            Name = $Matches['package']
            Hash = $Matches['packageHash']
        }

        $InputObject.Packages += $package

        $properties = [PSCustomObject]@{}
        $package | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $properties


        $LineEnumerator.MoveNextIgnoringBlank() > $null
        while ($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -ceq ':' -or $LineEnumerator.Current.Contains('=')) {
            if (-not $LineEnumerator.Current[0] -ceq ' ') {
                break
            }
            while ($LineEnumerator.Current -match 'User (?<userId>\d+):') {
                # TODO: Parse this correctly
                # For now we just skip them

                # $userId = [uint32] $Matches['userId']

                # $user = [PSCustomObject]@{
                #     UserId = $userId
                # }
                # if ($properties.PSObject.Properties.Name -notcontains 'Users') {
                #     $properties | Add-Member -MemberType NoteProperty -Name 'Users' -Value @()
                # }
                # $properties.Users += $user

                # $userProperties = [PSCustomObject]@{}
                # $user | Add-Member -MemberType NoteProperty -Name 'Properties' -Value $userProperties

                # $LineEnumerator.MoveNextIgnoringBlank() > $null
                # while ($LineEnumerator.Current -notmatch 'User \d+:') {
                #     if (-not $LineEnumerator.Current.StartsWith(' ')) {
                #         break
                #     }
                #     $LineEnumerator.MoveNextIgnoringBlank() > $null
                # }

                while (($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -ceq ':' -and $LineEnumerator.Current.StartsWith('    ')) -or $LineEnumerator.Current.StartsWith('      ') -or $LineEnumerator.Current -match 'User \d+:') {
                    $LineEnumerator.MoveNextIgnoringBlank() > $null
                }

                continue outer
            }

            if ($LineEnumerator.Current.Contains('versionCode') -or $LineEnumerator.Current.Contains('userId') -or $LineEnumerator.Current.Contains('permissionsFixed')) {
                $script:PackageKeyValuePairRegex.Matches($LineEnumerator.Current) `
                | ForEach-Object {
                    $attributeName = $_.Groups['attributeName'].Value
                    $attributeValue = $_.Groups['attributeValue'].Value

                    $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $attributeValue
                }
                $LineEnumerator.MoveNextIgnoringBlank() > $null
                continue
            }

            if ($LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -ceq ':') {
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
                $attributeValue = $valueSb.ToString().Trim()

                # [ HAS_CODE ALLOW_CLEAR_USER_DATA ]
                if ($attributeValue -match '^\[\s*(\w+(?:\s+\w+)*)\s*\]$') {
                    $attributeValue = $attributeValue.Trim('[', ']', ' ') -split '\s+'
                }
                # [base, chrome, config.en, config.es, config.fr]
                elseif ($attributeValue -match '^\[\s*(.+(?:\s*,\s*[\w.-]+)*)\s*\]$') {
                    $attributeValue = $attributeValue.Trim('[', ']', ' ') -split '\s*,\s*'
                }
                elseif ($attributeValue -eq '[]') {
                    $attributeValue = @()
                }

                $properties | Add-Member -MemberType NoteProperty -Name $attributeName -Value $attributeValue

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
        $camelCase = [System.Text.StringBuilder]::new($words[0].ToLowerInvariant())

        foreach ($word in $words[1..($words.Count - 1)]) {
            $camelCase.Append($word.Substring(0, 1).ToUpperInvariant() + $word.Substring(1).ToLowerInvariant()) > $null
        }
        return $camelCase.ToString()
    }

    return ""
}

function ConvertToPascalCase {

    param (
        [string] $InputObject
    )

    if ($InputObject -match ' ') {
        $words = $InputObject -split ' '
        $pascalCase = [System.Text.StringBuilder]::new()
        foreach ($word in $words) {
            $pascalCase.Append($word.Substring(0, 1).ToUpperInvariant()) > $null
            $pascalCase.Append($word.Substring(1).ToLowerInvariant()) > $null
        }
        return $pascalCase.ToString()
    }
}
