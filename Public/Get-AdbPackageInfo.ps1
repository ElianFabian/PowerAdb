function Get-AdbPackageInfo {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [string[]] $PackageName,

        [switch] $Raw,

        # Retrieves the packages to check if the current PackageName exist at the before processing the command.
        [switch] $ExhaustivePackageExistenceCheck
    )

    if (-not $PackageName) {
        $noPackage = $true
        $PackageName = @('*') # Arbitrary value to ensure we enter the loop exactly once
    }
    elseif (-not $ExhaustivePackageExistenceCheck) {
        $allInitialPackages = Get-AdbPackage -DeviceId $DeviceId -Verbose:$false
    }

    foreach ($package in $PackageName) {
        if (-not $noPackage) {
            $allPackages = if ($ExhaustivePackageExistenceCheck) {
                Get-AdbPackage -DeviceId $DeviceId -Verbose:$false
            }
            else {
                $allInitialPackages
            }

            $foundPackage = $allPackages `
            | Where-Object { $_ -eq $package } `
            | Select-Object -First 1

            if (-not $foundPackage) {
                $null
                continue
            }
        }

        $rawData = if ($noPackage) {
            Get-AdbServiceDump -DeviceId $DeviceId -Name 'package' -Verbose:$VerbosePreference
        }
        else {
            Get-AdbServiceDump -DeviceId $DeviceId -Name 'package' -ArgumentList $package -Verbose:$VerbosePreference
        }

        if ($Raw) {
            $rawData
            continue
        }

        $output = [PSCustomObject] @{}

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
                UserId      = [int] $Matches['userId']
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

        # TODO: Parse this (maybe)
        # At the moment we know that 'Domain verification status' is between 'Service Resolver Table' and "Permissions" section
        # Domain verification status:
        #   User all:
        #       Verification link handling allowed: true
        #       Selection state:
        #       Disabled:
        #           g.co
        if ($LineEnumerator.Current.StartsWith('Domain verification status:')) {
            # For now we just skip it
            do {
                $LineEnumerator.MoveNextIgnoringBlank() > $null
            }
            while ($LineEnumerator.Current[0] -ceq ' ')
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

                    $name = ConvertTo-PascalCase $rawName

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
            ParsePackages -LineEnumerator $lineEnumerator -Name 'Packages' -InputObject $output
        }
        if ($lineEnumerator.Current.Contains('Hidden system packages:')) {
            # FIXME: Even though Packages and Hidden system packages look similar something is failing and this is not being parsed.
            # ParsePackages -LineEnumerator $lineEnumerator -Name 'HiddenSystemPackages' -InputObject $output
        }
        if ($lineEnumerator.Current.Contains('Queries:')) {
            # Queries:
            #   system apps queryable: false
            #   queries via forceQueryable:
            #   forceQueryable:
            #     [com.google.pixel.camera.services,android,com.google.pixel.iwlan,com.android.server.telecom,com.android.dynsystem,com.android.DeviceAsWebcam,com.android.inputdevices,com.google.SSRestartDetector,com.android.settings,com.android.localtransport,com.android.providers.settings,com.google.android.settings.future.biometrics.faceenroll,com.google.android.repairmode,com.android.qns,com.android.location.fused,com.google.android.iwlan,com.android.keychain]
            #     [com.android.mms.service,com.android.providers.telephony,com.samsung.slsi.telephony.oem.oemrilhookservice,com.google.RilConfigService,com.android.ons,com.android.phone,com.google.android.telephony,com.android.stk,com.android.telephony.imsmedia]
            #     com.android.se
            #     [com.google.android.networkstack,com.google.android.networkstack.tethering,com.google.android.cellbroadcastservice]
            #     com.android.shell
            #     com.google.android.overlay.trafficlightfaceoverlay
            #     com.google.android.systemui.overlay.pixelvpnconfig
            #     com.google.android.wifi.resources.pixel
            #     com.google.android.uwb.resources.pixel
            #     com.google.android.settings.overlay.pixelvpnconfig
            #     com.google.euiccpixel.overlay.zuma
            #     com.google.android.overlay.udfpsoverlay
            #     com.google.android.systemui.overlay.pixelbatteryhealthconfig
            #     com.google.android.systemui.gxoverlay
            #     com.android.healthconnect.overlay
            #     com.android.role.notes.enabled
            #     [com.android.providers.blockednumber,com.android.providers.contactkeys,com.android.providers.contacts,com.android.providers.userdictionary,com.android.calllogbackup]
            #     [com.android.mtp,com.android.soundpicker,com.android.providers.media,com.android.providers.downloads,com.android.providers.downloads.ui]
            #     com.android.intentresolver
            #
            #     [...]
            #
            #       com.google.android.contacts:
            #         com.google.android.providers.media.module
            #       com.google.android.gm:
            #         com.google.android.providers.media.module
            #       com.brave.browser:
            #         com.google.android.providers.media.module
            #       com.volaplay.vola:
            #         com.google.android.providers.media.module
            #       es.fnmtrcm.ceres.certificadoDigitalFNMT:
            #         [com.android.mtp,com.android.soundpicker,com.android.providers.media,com.android.providers.downloads,com.android.providers.downloads.ui]
            #   queryable via uses-library:
        }
        if ($lineEnumerator.Current.Contains('Shared users:')) {
            # Shared users:
            #   SharedUser [android.media] (44ad45b):
            #     appId=10074
            #     Packages
            #       PackageSetting{1031521 com.android.mtp/10074}
            #       PackageSetting{7463d46 com.android.soundpicker/10074}
            #       PackageSetting{906b72b com.android.providers.media/10074}
            #       PackageSetting{9ed4788 com.android.providers.downloads/10074}
            #       PackageSetting{e55637a com.android.providers.downloads.ui/10074}
            #     install permissions:
            #       android.permission.ACCESS_CACHE_FILESYSTEM: granted=true
            #       android.permission.WRITE_SETTINGS: granted=true
            #       android.permission.MANAGE_EXTERNAL_STORAGE: granted=true
            #       com.android.providers.media.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: granted=true
            #       android.permission.SEND_DOWNLOAD_COMPLETED_INTENTS: granted=true
            #       android.permission.FOREGROUND_SERVICE: granted=true
            #       android.permission.RECEIVE_BOOT_COMPLETED: granted=true
            #       android.permission.WRITE_MEDIA_STORAGE: granted=true
            #       android.permission.INTERNET: granted=true
            #       com.android.soundpicker.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: granted=true
            #       android.permission.UPDATE_DEVICE_STATS: granted=true
            #       android.permission.RECEIVE_DEVICE_CUSTOMIZATION_READY: granted=true
            #       android.permission.MANAGE_USB: granted=true
            #       android.permission.ACCESS_ALL_DOWNLOADS: granted=true
            #       android.permission.ACCESS_DOWNLOAD_MANAGER: granted=true
            #       android.permission.FOREGROUND_SERVICE_DATA_SYNC: granted=true
            #       android.permission.MANAGE_USERS: granted=true
            #       android.permission.ACCESS_NETWORK_STATE: granted=true
            #       android.permission.ACCESS_MTP: granted=true
            #       android.permission.INTERACT_ACROSS_USERS: granted=true
            #       android.permission.CONNECTIVITY_USE_RESTRICTED_NETWORKS: granted=true
            #       android.permission.CLEAR_APP_CACHE: granted=true
            #       android.permission.CONNECTIVITY_INTERNAL: granted=true
            #       android.permission.START_ACTIVITIES_FROM_BACKGROUND: granted=true
            #       com.android.mtp.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: granted=true
            #       android.permission.QUERY_ALL_PACKAGES: granted=true
            #       android.permission.WAKE_LOCK: granted=true
            #       android.permission.UPDATE_APP_OPS_STATS: granted=true
            #     User 0:
            #       gids=[2001, 3003, 3007, 1024]
            #       runtime permissions:
            #         android.permission.POST_NOTIFICATIONS: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT]
            #         android.permission.READ_EXTERNAL_STORAGE: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT|REVOKE_WHEN_REQUESTED|RESTRICTION_SYSTEM_EXEMPT|RESTRICTION_UPGRADE_EXEMPT]
            #         android.permission.WRITE_EXTERNAL_STORAGE: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT|RESTRICTION_SYSTEM_EXEMPT|RESTRICTION_UPGRADE_EXEMPT]
            #     User 10:
            #       gids=[2001, 3003, 3007, 1024]
            #       runtime permissions:
            #         android.permission.POST_NOTIFICATIONS: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT]
            #         android.permission.READ_EXTERNAL_STORAGE: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT|REVOKE_WHEN_REQUESTED|RESTRICTION_SYSTEM_EXEMPT|RESTRICTION_UPGRADE_EXEMPT]
            #         android.permission.WRITE_EXTERNAL_STORAGE: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT|RESTRICTION_SYSTEM_EXEMPT|RESTRICTION_UPGRADE_EXEMPT]
            #     User 11:
            #       gids=[2001, 3003, 3007, 1024]
            #       runtime permissions:
            #         android.permission.POST_NOTIFICATIONS: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT]
            #         android.permission.READ_EXTERNAL_STORAGE: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT|REVOKE_WHEN_REQUESTED|RESTRICTION_SYSTEM_EXEMPT|RESTRICTION_UPGRADE_EXEMPT]
            #         android.permission.WRITE_EXTERNAL_STORAGE: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT|RESTRICTION_SYSTEM_EXEMPT|RESTRICTION_UPGRADE_EXEMPT]
            #     [...]
        }
        if ($lineEnumerator.Current.Contains('Package Changes:')) {
            # Sequence number=4952
            #   User 0:
            #     seq=1, package=com.android.settings
            #     seq=284, package=com.eva.bluetoothterminalapp.debug
            #     seq=893, package=com.google.android.keep
            #     seq=921, package=com.google.android.apps.scone
            #     seq=922, package=com.google.android.odad
            #     seq=941, package=com.google.android.trichromelibrary_710308833
            #     seq=944, package=com.google.android.as
            #     seq=946, package=com.google.android.apps.wellbeing
            #     [...]
        }
        if ($lineEnumerator.Current.Contains('Frozen packages:')) {
            # Frozen packages:
            #   (none)
        }
        if ($lineEnumerator.Current.Contains('Loaded volumes:')) {
            # Loaded volumes:
            #   (none)
        }
        if ($lineEnumerator.Current.Contains('Service permissions:')) {
            # Service permissions:
            #     org.breezyweather/.background.interfaces.TileService: android.permission.BIND_QUICK_SETTINGS_TILE
            #     com.google.android.dialer/com.android.incallui.InCallServiceImpl: android.permission.BIND_INCALL_SERVICE
            #     com.google.pixel.livewallpaper/.split.FeatureDeletionService: android.permission.BIND_WALLPAPER
            #     com.twitter.android/com.twitter.calling.xcall.XCallConnectionService: android.permission.BIND_TELECOM_CONNECTION_SERVICE
            #     org.breezyweather/.wallpaper.MaterialLiveWallpaperService: android.permission.BIND_WALLPAPER
            #     com.google.android.apps.carrier.carrierwifi/.wifiscorer.WifiScorerService: android.permission.NETWORK_STACK
            #     com.android.hotwordenrollment.okgoogle/.EnrollmentForegroundIntentService: android.permission.MANAGE_VOICE_KEYPHRASES
            #     com.android.chrome/com.google.ipc.invalidation.ticl.android2.channel.GcmRegistrationTaskService: com.google.android.gms.permission.BIND_NETWORK_TASK_SERVICE
            #     com.google.pixel.livewallpaper/.tactile.wallpapers.offsetbloom.TactileWallpaperOffsetBloom: android.permission.BIND_WALLPAPER
            #     com.google.android.projection.gearhead/com.google.android.apps.auto.components.telecom.service.NonCarInCallServiceImpl: android.permission.BIND_INCALL_SERVICE
            #     [...]
        }
        if ($lineEnumerator.Current.Contains('Dexopt state:')) {
            # [android]
            #   [android.auto_generated_characteristics_rro]
            #   [android.auto_generated_rro_product__]
            #   [android.auto_generated_rro_vendor__]
            #   [android.autoinstalls.config.google.nexus]
            #     path: /product/app/PlayAutoInstallConfig/PlayAutoInstallConfig.apk
            #       arm64: [status=verify] [reason=vdex] [primary-abi]
            #         [location is /data/dalvik-cache/arm64/product@app@PlayAutoInstallConfig@PlayAutoInstallConfig.apk@classes.vdex]
            #   [apitester.org]
            #     path: /data/app/~~X1mJGgAgIgLqdGNKW6bCwA==/apitester.org-C-5YaXHPrKYpJn8qIF2SUg==/base.apk
            #       arm64: [status=speed-profile] [reason=install-dm] [primary-abi]
            #         [location is /data/app/~~X1mJGgAgIgLqdGNKW6bCwA==/apitester.org-C-5YaXHPrKYpJn8qIF2SUg==/oat/arm64/base.odex]
            #   [app.revanced.android.gms]
            #     path: /data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk
            #       arm64: [status=speed] [reason=ab-ota] [primary-abi]
            #         [location is /data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/oat/arm64/base.odex]
            #       used by other apps: [app.revanced.android.youtube (isa=arm64)]
            #     known secondary dex files:
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/102afa65cbdeba71c21993dcd8b2824ebc4ab638/the.apk
            #         arm64: [status=verify] [reason=vdex] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/102afa65cbdeba71c21993dcd8b2824ebc4ab638/oat/arm64/the.vdex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/18c5b41ea396685fb58369434f5284598653fc52/the.apk (public)
            #         arm64: [status=verify] [reason=vdex] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/18c5b41ea396685fb58369434f5284598653fc52/oat/arm64/the.vdex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/1f9311f70fee1d231a5d7e3c4384bf8c9cbccc33/the.apk (public)
            #         arm64: [status=verify] [reason=bg-dexopt] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/1f9311f70fee1d231a5d7e3c4384bf8c9cbccc33/oat/arm64/the.odex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/34980e504d434d98ba315821ed93826a1b7437e5/the.apk (public)
            #         arm64: [status=verify] [reason=vdex] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/34980e504d434d98ba315821ed93826a1b7437e5/oat/arm64/the.vdex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/3d573230b414a21389bebba9396f986074fefd21/the.apk
            #         arm64: [status=verify] [reason=vdex] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/3d573230b414a21389bebba9396f986074fefd21/oat/arm64/the.vdex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/64d52f9967b09adc38f66106dceb0c95acbc9d36/the.apk (public)
            #         arm64: [status=verify] [reason=vdex] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/64d52f9967b09adc38f66106dceb0c95acbc9d36/oat/arm64/the.vdex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/82400ce807412cb0e06581a260163e6ba9db8553/the.apk (public)
            #         arm64: [status=verify] [reason=bg-dexopt] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/82400ce807412cb0e06581a260163e6ba9db8553/oat/arm64/the.odex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/cbc7fea12a635adb3272885135485edfb7ef99ca/the.apk
            #         arm64: [status=verify] [reason=bg-dexopt] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/cbc7fea12a635adb3272885135485edfb7ef99ca/oat/arm64/the.odex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #       /data/user/0/app.revanced.android.gms/app_cache_dg/ce01f034a0dff0b068399662cab73ab2d7ea27fe/the.apk
            #         arm64: [status=verify] [reason=vdex] [primary-abi]
            #           [location is /data/user/0/app.revanced.android.gms/app_cache_dg/ce01f034a0dff0b068399662cab73ab2d7ea27fe/oat/arm64/the.vdex]
            #         class loader context: PCL[];PCL[/data/app/~~u0AqBpj6d7UKH3cbV8jUwg==/app.revanced.android.gms-cC9veGuFYLGBXi0yeCoPRg==/base.apk]{PCL[/system/framework/android.test.base.jar]#PCL[/system/framework/com.android.location.provider.jar]#PCL[/system/framework/org.apache.http.legacy.jar]#PCL[/system_ext/framework/androidx.window.extensions.jar]#PCL[/system_ext/framework/androidx.window.sidecar.jar]}
            #
            #     [...]
            #
            #   Current GC: CollectorTypeCMC
        }
        if ($lineEnumerator.Current.Contains('Compiler stats:')) {
            # Compiler stats:
            #   [com.google.android.uvexposurereporter]
            #     (No recorded stats)
            #   [com.android.internal.display.cutout.emulation.noCutout]
            #     (No recorded stats)
            #   [com.google.android.gms]
            #      dl-VisionFace.optional_251332100400.apk - 1377
            #      dl-MlkitDocscanUi.optional_251332100400.apk - 1084
            #      dl-VisionIca.optional_251134100400.apk - 544
            #      dl-VisionCustomIca.optional_251731100400.apk - 635
            #      dl-VisionFace.optional_251731100400.apk - 728
            #      dl-VisionCustomIca.optional_251833100400.apk - 815
            #      dl-BrellaDynamite.optional_251332100400.apk - 334
            #      dl-VisionCustomIca.optional_251134100400.apk - 640
            #      dl-Fastpair.optional_251332100000.apk - 650
            #      dl-Games.optional_251332100000.apk - 766
            #      dl-PlayCloudSearch.optional_251332100000.apk - 532
            #      dl-VisionBarcode.optional_251332100400.apk - 543
            #      dl-VisionOcr.optional_251332100000.apk - 249
            #      dl-MlkitOcrCommon.optional_251332100400.apk - 328
            #      dl-VisionIca.optional_251731100400.apk - 531
            #   [com.google.android.gsf]
            #     (No recorded stats)
            #   [com.google.android.tag]
            #     (No recorded stats)
            #   [com.google.android.tts]
            #     (No recorded stats)
        }
        if ($lineEnumerator.Current.Contains('Settings parse messages:')) {
            # Settings parse messages:
            #
        }
        if ($lineEnumerator.Current.Contains('Package warning messages:')) {
            # Package warning messages:
            # 3/9/25 9:13 AM: No package manager settings file
            # 3/9/25 9:13 AM: Adding duplicate shared id: 1000 name=android
            # 3/9/25 9:13 AM: Adding duplicate shared id: 1001 name=com.android.ons
            # 3/9/25 9:13 AM: Adding duplicate app id: 10073 name=com.android.calllogbackup
            # 3/9/25 9:13 AM: Adding duplicate app id: 10074 name=com.android.providers.downloads
            # 3/9/25 9:13 AM: Adding duplicate app id: 10074 name=com.android.providers.downloads.ui
            #
            #     [...]
            #
            # 1/4/2025 11:22 p.m.: Upgrading from b0b103cd79fffaa0d00f9f61a1e6901d4d564efa (google/husky/husky:14/AP1A.240305.019.A1/11445699:user/release-keys) to 99e213b635c0247319094e6cf46b49c035358ee4 (google/husky/husky:15/BP1A.250305.019/13003188:user/release-keys)
            # 1/4/2025 11:22 p.m.: Adding duplicate app id: 10073 name=com.android.providers.contactkeys
            # 1/4/2025 11:22 p.m.: Package com.android.wallpaperbackup shared user changed from android.uid.system to <nothing>; replacing with new
            # 1/4/2025 11:22 p.m.: System package updated; name: com.google.android.GoogleCamera; 67635210 --> 67635286; /data/app/~~GoFDDWPzpmOI9H_R0Up1zw==/com.google.android.GoogleCamera-zMKl9jfXRlCMuodmFZ8qfw== --> /product/priv-app/GoogleCamera
            # 1/4/2025 11:22 p.m.: System package updated; name: com.android.chrome; 609919332 --> 661308832; /data/app/~~FS_JvbO7Z2hwgeaH_W58TQ==/com.android.chrome-SFCtKgsy1XG228oHMNNUpw== --> /product/app/Chrome-Stub
            # 1/4/2025 11:22 p.m.: System package updated; name: com.google.android.webview; 609919332 --> 661308832; /data/app/~~kyNmWCky3_iLds0ZVjV0PA==/com.google.android.webview-XrXxoR0QJ_fz-6yvfBaZ7Q== --> /product/app/WebViewGoogle-Stub
            #
            #     [...]
            #
            # 1/4/2025 11:22 p.m.: Updated system package com.google.android.trichromelibrary_609919332 no longer exists; rescanning package on data
            # 1/4/2025 11:22 p.m.: Failed to create app data for com.android.wallpaperbackup, but trying to recover: com.android.server.pm.Installer$InstallerException: Failed to prepare /data/user_de/0/com.android.wallpaperbackup
            # 1/4/2025 11:22 p.m.: Recovery succeeded!
            # 1/4/2025 11:23 p.m.: Failed to create app data for com.android.wallpaperbackup, but trying to recover: com.android.server.pm.Installer$InstallerException: Failed to prepare /data/data/com.android.wallpaperbackup
            # 1/4/2025 11:23 p.m.: Recovery succeeded!
            # 2/4/2025 12:31 a.m.: Destroying /data/user_de/10/com.google.android.sdksandbox due to: com.android.server.pm.PackageManagerException: Package com.google.android.sdksandbox shouldn't have storage
            # 2/4/25 11:11: Deleting invalid package at /data/app/~~CvER3JF9B8A_eb3P6uvRCQ==
            # 2/4/25 11:11: Deleting invalid package at /data/app/~~QLdJUM5t-aUGJTO17q4Yuw==
            #
            #     [...]
            #
            # 5/18/25 9:47 AM: Upgrading from 7940679239e5aced4aeee609516eab495a4f5b7c (google/husky/husky:15/BP1A.250405.007.B1/13240308:user/release-keys) to a18c8a2ab7519d77e1730574b264065914cc7b3f (google/husky/husky:15/BP1A.250505.005.B1/13277630:user/release-keys)
            # 5/18/25 9:47 AM: System package com.google.android.gsf signature changed; retaining data.
            # 5/22/25 9:40 AM: Destroying /data/user_de/11/com.google.android.sdksandbox due to: com.android.server.pm.PackageManagerException: Package com.google.android.sdksandbox shouldn't have storage
        }
        if ($lineEnumerator.Current.Contains('Active install sessions:')) {
            # Active install sessions:
            #   Active Session 201486112:
            #     userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #     installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #     installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1749252947784 updatedMillis=1749252950408
            #     committedMillis=1749252947851 stageDir=null stageCid=null
            #     mode=1 installFlags=0x440002 installLocation=1 installReason=0 installScenario=0 sizeBytes=-1
            #     appPackageName=com.google.mainline.telemetry appIcon=false appLabel=null originatingUri=null originatingUid=-1
            #     referrerUri=null abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0
            #     whitelistedRestrictedPermissions=null autoRevokePermissions=3 installerPackageName=null isMultiPackage=true
            #     isStaged=true forceQueryable=false requireUserAction=UNSPECIFIED requiredInstalledVersionCode=-1
            #     dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0 rollbackImpactLevel=0
            #     applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1 dexoptCompilerFilter=null
            #     isAutoInstallDependenciesEnabled=true
            #     mClientProgress=1.0 mProgress=0.8 mCommitted=true mPreapprovalRequested=false mSealed=true
            #     mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=0 mFinalStatus=0
            #     mFinalMessage=null params.isMultiPackage=true params.isStaged=true mParentSessionId=-1
            #     mChildSessionIds=[329255570, 1789153456] mSessionApplied=false mSessionFailed=false mSessionReady=true
            #     mSessionErrorCode=0 mSessionErrorMessage= mPreapprovalDetails=null

            #     Active Child Session 329255570:
            #       userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #       installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #       installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1749252943358 updatedMillis=1749252943358
            #       committedMillis=1749252947845 stageDir=/data/app-staging/session_329255570 stageCid=null
            #       mode=1 installFlags=0x2444012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1
            #       appPackageName=com.google.mainline.telemetry appIcon=false appLabel=Google Play system update
            #       originatingUri=null originatingUid=-1 referrerUri=null abiOverride=null volumeUuid=null mPermissionStates={}
            #       packageSource=0 whitelistedRestrictedPermissions=null autoRevokePermissions=3 installerPackageName=null
            #       isMultiPackage=false isStaged=true forceQueryable=false requireUserAction=UNSPECIFIED
            #       requiredInstalledVersionCode=-1 dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0
            #       rollbackImpactLevel=0 applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1
            #       dexoptCompilerFilter=null isAutoInstallDependenciesEnabled=true
            #       mClientProgress=1.0 mProgress=0.90000004 mCommitted=true mPreapprovalRequested=false mSealed=true
            #       mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=1 mFinalStatus=0
            #       mFinalMessage=null params.isMultiPackage=false params.isStaged=true mParentSessionId=201486112
            #       mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #       mSessionErrorMessage= mPreapprovalDetails=null

            #     Active Child Session 1789153456:
            #       userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #       installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #       installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1749252943467 updatedMillis=1749252943467
            #       committedMillis=1749252947851 stageDir=/data/app-staging/session_1789153456 stageCid=null
            #       mode=1 installFlags=0x464012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1
            #       appPackageName=com.google.android.os.statsd appIcon=false appLabel=Google Play system update originatingUri=null
            #       originatingUid=-1 referrerUri=null abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0
            #       whitelistedRestrictedPermissions=null autoRevokePermissions=3 installerPackageName=null isMultiPackage=false
            #       isStaged=true forceQueryable=false requireUserAction=UNSPECIFIED requiredInstalledVersionCode=-1
            #       dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0 rollbackImpactLevel=0
            #       applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1 dexoptCompilerFilter=null
            #       isAutoInstallDependenciesEnabled=true
            #       mClientProgress=1.0 mProgress=0.8 mCommitted=true mPreapprovalRequested=false mSealed=true
            #       mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=1 mFinalStatus=0
            #       mFinalMessage=null params.isMultiPackage=false params.isStaged=true mParentSessionId=201486112
            #       mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #       mSessionErrorMessage= mPreapprovalDetails=null
            #
            #     [...]
        }
        if ($lineEnumerator.Current.Contains('Finalized install sessions:')) {
            # Finalized install sessions:
            #   Finalized Session 115337069:
            #     userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #     installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #     installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1746615595222 updatedMillis=1746615595222
            #     committedMillis=1746615595299 stageDir=null stageCid=null
            #     mode=1 installFlags=0x640002 installLocation=1 installReason=0 installScenario=0 sizeBytes=-1
            #     appPackageName=com.google.mainline.telemetry appIcon=false appLabel=null originatingUri=null originatingUid=-1
            #     referrerUri=null abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0
            #     whitelistedRestrictedPermissions=null autoRevokePermissions=3 installerPackageName=null isMultiPackage=true
            #     isStaged=true forceQueryable=false requireUserAction=UNSPECIFIED requiredInstalledVersionCode=-1
            #     dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0 rollbackImpactLevel=0
            #     applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1 dexoptCompilerFilter=null
            #     isAutoInstallDependenciesEnabled=true
            #     mClientProgress=0.0 mProgress=0.0 mCommitted=true mPreapprovalRequested=false mSealed=false
            #     mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=0 mFinalStatus=0
            #     mFinalMessage=null params.isMultiPackage=true params.isStaged=true mParentSessionId=-1
            #     mChildSessionIds=[37160858, 2045096801] mSessionApplied=true mSessionFailed=false mSessionReady=false
            #     mSessionErrorCode=1 mSessionErrorMessage= mPreapprovalDetails=null

            #     Finalized Child Session 2045096801:
            #       userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #       installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #       installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1746615593782 updatedMillis=1746615593782
            #       committedMillis=1746615595298 stageDir=/data/app-staging/session_2045096801 stageCid=null
            #       mode=1 installFlags=0x2644012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1
            #       appPackageName=com.google.mainline.telemetry appIcon=false appLabel=Google Play system update
            #       originatingUri=null originatingUid=-1 referrerUri=null abiOverride=null volumeUuid=null mPermissionStates={}
            #       packageSource=0 whitelistedRestrictedPermissions=null autoRevokePermissions=3 installerPackageName=null
            #       isMultiPackage=false isStaged=true forceQueryable=false requireUserAction=UNSPECIFIED
            #       requiredInstalledVersionCode=-1 dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0
            #       rollbackImpactLevel=0 applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1
            #       dexoptCompilerFilter=null isAutoInstallDependenciesEnabled=true
            #       mClientProgress=0.0 mProgress=0.0 mCommitted=true mPreapprovalRequested=false mSealed=true
            #       mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=0 mFinalStatus=0
            #       mFinalMessage=null params.isMultiPackage=false params.isStaged=true mParentSessionId=115337069
            #       mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #       mSessionErrorMessage= mPreapprovalDetails=null

            #     Finalized Child Session 37160858:
            #       userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #       installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #       installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1746615593788 updatedMillis=1746615593788
            #       committedMillis=1746615595293 stageDir=/data/app-staging/session_37160858 stageCid=null
            #       mode=1 installFlags=0x464012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1
            #       appPackageName=com.google.android.os.statsd appIcon=false appLabel=Google Play system update originatingUri=null
            #       originatingUid=-1 referrerUri=null abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0
            #       whitelistedRestrictedPermissions=null autoRevokePermissions=3 installerPackageName=null isMultiPackage=false
            #       isStaged=true forceQueryable=false requireUserAction=UNSPECIFIED requiredInstalledVersionCode=-1
            #       dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0 rollbackImpactLevel=0
            #       applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1 dexoptCompilerFilter=null
            #       isAutoInstallDependenciesEnabled=true
            #       mClientProgress=0.0 mProgress=0.0 mCommitted=true mPreapprovalRequested=false mSealed=true
            #       mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=0 mFinalStatus=0
            #       mFinalMessage=null params.isMultiPackage=false params.isStaged=true mParentSessionId=115337069
            #       mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #       mSessionErrorMessage= mPreapprovalDetails=null
            #
            #     [...]
        }
        if ($lineEnumerator.Current.Contains('Historical install sessions::')) {
            # Historical install sessions:
            #   Session 568076127:
            #     userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #     installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #     installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1748422196344 updatedMillis=1748422196344
            #     committedMillis=1748422215596 stageDir=/data/app-staging/session_568076127 stageCid=null
            #     mode=1 installFlags=0x464012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1 appPackageName=com.goo
            #     gle.android.healthfitness appIcon=false appLabel=Google Play system update originatingUri=null originatingUid=-1 ref
            #     errerUri=null abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0 whitelistedRestrictedPermissions
            #     =null autoRevokePermissions=3 installerPackageName=null isMultiPackage=false isStaged=true forceQueryable=false requ
            #     ireUserAction=UNSPECIFIED requiredInstalledVersionCode=-1 dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetim
            #     eMillis=0 rollbackImpactLevel=0 applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1
            #      dexoptCompilerFilter=null isAutoInstallDependenciesEnabled=true
            #     mClientProgress=1.0 mProgress=0.8 mCommitted=true mPreapprovalRequested=false mSealed=true
            #     mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=1 mFinalStatus=-115
            #     mFinalMessage=Session was abandoned because the parent session is abandoned mParentSessionId=183625636
            #     mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #     mSessionErrorMessage= mPreapprovalDetails=null mPreVerifiedDomains=null
            #     mAppPackageName=com.google.android.healthfitness

            #   Session 699502750:
            #     userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #     installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #     installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1748422196374 updatedMillis=1748422196374
            #     committedMillis=1748422215638 stageDir=/data/app-staging/session_699502750 stageCid=null
            #     mode=1 installFlags=0x464012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1 appPackageName=com.goo
            #     gle.android.art appIcon=false appLabel=Google Play system update originatingUri=null originatingUid=-1 referrerUri=n
            #     ull abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0 whitelistedRestrictedPermissions=null auto
            #     RevokePermissions=3 installerPackageName=null isMultiPackage=false isStaged=true forceQueryable=false requireUserAct
            #     ion=UNSPECIFIED requiredInstalledVersionCode=-1 dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMillis=0
            #     rollbackImpactLevel=0 applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1 dexoptCom
            #     pilerFilter=null isAutoInstallDependenciesEnabled=true
            #     mClientProgress=1.0 mProgress=0.8 mCommitted=true mPreapprovalRequested=false mSealed=true
            #     mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=1 mFinalStatus=-115
            #     mFinalMessage=Session was abandoned because the parent session is abandoned mParentSessionId=183625636
            #     mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #     mSessionErrorMessage= mPreapprovalDetails=null mPreVerifiedDomains=null mAppPackageName=com.google.android.art

            #   Session 1014910738:
            #     userId=0 mOriginalInstallerUid=10128 mOriginalInstallerPackageName=com.android.vending
            #     installerPackageName=com.android.vending installInitiatingPackageName=com.android.vending
            #     installOriginatingPackageName=null mInstallerUid=10128 createdMillis=1748422196381 updatedMillis=1748422196381
            #     committedMillis=1748422215640 stageDir=/data/app-staging/session_1014910738 stageCid=null
            #     mode=1 installFlags=0x464012 installLocation=1 installReason=4 installScenario=0 sizeBytes=-1 appPackageName=com.goo
            #     gle.android.scheduling appIcon=false appLabel=Google Play system update originatingUri=null originatingUid=-1 referr
            #     erUri=null abiOverride=null volumeUuid=null mPermissionStates={} packageSource=0 whitelistedRestrictedPermissions=nu
            #     ll autoRevokePermissions=3 installerPackageName=null isMultiPackage=false isStaged=true forceQueryable=false require
            #     UserAction=UNSPECIFIED requiredInstalledVersionCode=-1 dataLoaderParams=null rollbackDataPolicy=0 rollbackLifetimeMi
            #     llis=0 rollbackImpactLevel=0 applicationEnabledSettingPersistent=false developmentInstallFlags=0x0 unarchiveId=-1 de
            #     xoptCompilerFilter=null isAutoInstallDependenciesEnabled=true
            #     mClientProgress=1.0 mProgress=0.8 mCommitted=true mPreapprovalRequested=false mSealed=true
            #     mPermissionsManuallyAccepted=false mStageDirInUse=false mDestroyed=false mFds=0 mBridges=1 mFinalStatus=-115
            #     mFinalMessage=Session was abandoned because the parent session is abandoned mParentSessionId=183625636
            #     mChildSessionIds=[] mSessionApplied=false mSessionFailed=false mSessionReady=false mSessionErrorCode=0
            #     mSessionErrorMessage= mPreapprovalDetails=null mPreVerifiedDomains=null
            #     mAppPackageName=com.google.android.scheduling
        }
        if ($lineEnumerator.Current.Contains('Legacy install sessions:')) {
            # Legacy install sessions:
            #   {}
        }
        if ($lineEnumerator.Current.Contains('Gentle update with constraints info:')) {
            # Gentle update with constraints info:
            #   hasPendingIdleJob=false
            #   Num of PendingIdleFutures=0
            #   Num of PendingChecks=0
        }
        if ($lineEnumerator.Current.Contains('APEX session state:')) {
            # APEX session state:
            #   Session ID: 140483565
            #     State: STAGED
            #   Session ID: 201486112
            #     State: STAGED
            #   Session ID: 1280984337
            #     State: STAGED
        }
        if ($lineEnumerator.Current.Contains('Active APEX packages:')) {
            # Active APEX packages:

            #   com.google.android.devicelock
            #     Version: 1
            #     Path: /system/apex/com.google.android.devicelock.apex
            #     IsActive: true
            #     IsFactory: true
            #     ApplicationInfo:
            #       packageName=com.google.android.devicelock
            #       processName=com.google.android.devicelock
            #       taskAffinity=com.google.android.devicelock
            #       uid=-1 flags=0x3008be41 privateFlags=0x8c001000 theme=0x0
            #       requiresSmallestWidthDp=0 compatibleWidthLimitDp=0 largestWidthLimitDp=0
            #       sourceDir=/system/apex/com.google.android.devicelock.apex
            #       dataDir=null
            #       deviceProtectedDataDir=null
            #       credentialProtectedDataDir=null
            #       enabled=true minSdkVersion=34 targetSdkVersion=35 versionCode=1 targetSandboxVersion=1
            #       supportsRtl=false
            #       fullBackupContent=true
            #       crossProfile=false
            #       HiddenApiEnforcementPolicy=2
            #       usesNonSdkApi=false
            #       allowsPlaybackCapture=true
            #       nativeHeapZeroInitialized=0
            #       enableOnBackInvokedCallback=false
            #       allowCrossUidActivitySwitchFromBelow=true
            #       mPageSizeAppCompatFlags=0
            #       createTimestamp=1057065903
            #   com.google.android.tzdata6
            #     Version: 351400020
            #     Path: /data/apex/active/com.android.tzdata@351400020.apex
            #     IsActive: true
            #     IsFactory: false
            #     ApplicationInfo:
            #       packageName=com.google.android.tzdata6
            #       processName=com.google.android.tzdata6
            #       taskAffinity=com.google.android.tzdata6
            #       uid=-1 flags=0x3008be41 privateFlags=0x8c001000 theme=0x0
            #       requiresSmallestWidthDp=0 compatibleWidthLimitDp=0 largestWidthLimitDp=0
            #       sourceDir=/data/apex/active/com.android.tzdata@351400020.apex
            #       dataDir=null
            #       deviceProtectedDataDir=null
            #       credentialProtectedDataDir=null
            #       enabled=true minSdkVersion=33 targetSdkVersion=35 versionCode=351400020 targetSandboxVersion=1
            #       supportsRtl=false
            #       fullBackupContent=true
            #       crossProfile=false
            #       HiddenApiEnforcementPolicy=2
            #       usesNonSdkApi=false
            #       allowsPlaybackCapture=true
            #       nativeHeapZeroInitialized=0
            #       enableOnBackInvokedCallback=false
            #       allowCrossUidActivitySwitchFromBelow=true
            #       mPageSizeAppCompatFlags=0
            #       createTimestamp=1057065903
        }
        if ($lineEnumerator.Current.Contains('Inactive APEX packages:')) {
            # Inactive APEX packages:

            #   com.google.android.tzdata6
            #     Version: 351010000
            #     Path: /system/apex/com.google.android.tzdata6.apex
            #     IsActive: false
            #     IsFactory: true
            #     ApplicationInfo:
            #       packageName=com.google.android.tzdata6
            #       processName=com.google.android.tzdata6
            #       taskAffinity=com.google.android.tzdata6
            #       uid=-1 flags=0x3008be41 privateFlags=0x8c001000 theme=0x0
            #       requiresSmallestWidthDp=0 compatibleWidthLimitDp=0 largestWidthLimitDp=0
            #       sourceDir=/system/apex/com.google.android.tzdata6.apex
            #       dataDir=null
            #       deviceProtectedDataDir=null
            #       credentialProtectedDataDir=null
            #       enabled=true minSdkVersion=33 targetSdkVersion=35 versionCode=351010000 targetSandboxVersion=1
            #       supportsRtl=false
            #       fullBackupContent=true
            #       crossProfile=false
            #       HiddenApiEnforcementPolicy=2
            #       usesNonSdkApi=false
            #       allowsPlaybackCapture=true
            #       nativeHeapZeroInitialized=0
            #       enableOnBackInvokedCallback=false
            #       allowCrossUidActivitySwitchFromBelow=true
            #       mPageSizeAppCompatFlags=0
            #       createTimestamp=1057065908
            #   com.google.android.ondevicepersonalization
            #     Version: 351121040
            #     Path: /system/apex/com.google.android.ondevicepersonalization.apex
            #     IsActive: false
            #     IsFactory: true
            #     ApplicationInfo:
            #       packageName=com.google.android.ondevicepersonalization
            #       processName=com.google.android.ondevicepersonalization
            #       taskAffinity=com.google.android.ondevicepersonalization
            #       uid=-1 flags=0x3008be41 privateFlags=0x8c001000 theme=0x0
            #       requiresSmallestWidthDp=0 compatibleWidthLimitDp=0 largestWidthLimitDp=0
            #       sourceDir=/system/apex/com.google.android.ondevicepersonalization.apex
            #       dataDir=null
            #       deviceProtectedDataDir=null
            #       credentialProtectedDataDir=null
            #       enabled=true minSdkVersion=33 targetSdkVersion=35 versionCode=351121040 targetSandboxVersion=1
            #       supportsRtl=false
            #       fullBackupContent=true
            #       crossProfile=false
            #       HiddenApiEnforcementPolicy=2
            #       usesNonSdkApi=false
            #       allowsPlaybackCapture=true
            #       nativeHeapZeroInitialized=0
            #       enableOnBackInvokedCallback=false
            #       allowCrossUidActivitySwitchFromBelow=true
            #       mPageSizeAppCompatFlags=0
            #       createTimestamp=1057065908
        }
        if ($lineEnumerator.Current.Contains('Factory APEX packages:')) {
            # Factory APEX packages:

            #   com.google.android.devicelock
            #     Version: 1
            #     Path: /system/apex/com.google.android.devicelock.apex
            #     IsActive: true
            #     IsFactory: true
            #     ApplicationInfo:
            #       packageName=com.google.android.devicelock
            #       processName=com.google.android.devicelock
            #       taskAffinity=com.google.android.devicelock
            #       uid=-1 flags=0x3008be41 privateFlags=0x8c001000 theme=0x0
            #       requiresSmallestWidthDp=0 compatibleWidthLimitDp=0 largestWidthLimitDp=0
            #       sourceDir=/system/apex/com.google.android.devicelock.apex
            #       dataDir=null
            #       deviceProtectedDataDir=null
            #       credentialProtectedDataDir=null
            #       enabled=true minSdkVersion=34 targetSdkVersion=35 versionCode=1 targetSandboxVersion=1
            #       supportsRtl=false
            #       fullBackupContent=true
            #       crossProfile=false
            #       HiddenApiEnforcementPolicy=2
            #       usesNonSdkApi=false
            #       allowsPlaybackCapture=true
            #       nativeHeapZeroInitialized=0
            #       enableOnBackInvokedCallback=false
            #       allowCrossUidActivitySwitchFromBelow=true
            #       mPageSizeAppCompatFlags=0
            #       createTimestamp=1057065910
            #   com.android.hardware.biometrics.face.virtual
            #     Version: 2
            #     Path: /system_ext/apex/com.android.hardware.biometrics.face.virtual.apex
            #     IsActive: true
            #     IsFactory: true
            #     ApplicationInfo:
            #       packageName=com.android.hardware.biometrics.face.virtual
            #       processName=com.android.hardware.biometrics.face.virtual
            #       taskAffinity=com.android.hardware.biometrics.face.virtual
            #       uid=-1 flags=0x3008be41 privateFlags=0x8c201000 theme=0x0
            #       requiresSmallestWidthDp=0 compatibleWidthLimitDp=0 largestWidthLimitDp=0
            #       sourceDir=/system_ext/apex/com.android.hardware.biometrics.face.virtual.apex
            #       dataDir=null
            #       deviceProtectedDataDir=null
            #       credentialProtectedDataDir=null
            #       enabled=true minSdkVersion=35 targetSdkVersion=35 versionCode=2 targetSandboxVersion=1
            #       supportsRtl=false
            #       fullBackupContent=true
            #       crossProfile=false
            #       HiddenApiEnforcementPolicy=2
            #       usesNonSdkApi=false
            #       allowsPlaybackCapture=true
            #       nativeHeapZeroInitialized=0
            #       enableOnBackInvokedCallback=false
            #       allowCrossUidActivitySwitchFromBelow=true
            #       mPageSizeAppCompatFlags=0
            #       createTimestamp=1057065910
        }
        if ($lineEnumerator.Current.Contains('Per UID read timeouts:')) {
            # Per UID read timeouts:
            #     Default timeouts flag:
            #     Known digesters list flag:
            #     Timeouts (0):
        }
        if ($lineEnumerator.Current.Contains('Snapshot statistics:')) {
            # Snapshot statistics:
            #     Unrecorded-hits: 33098
            #     Summary stats               TotBlds     TotUsed     BigBlds    ShortLvd     TotTime     MaxTime
            #            0:18         now           0           0           0           0           0           0
            #            1:18        0:18           0           0           0           0           0           0
            #            6:00        1:18           0           0           0           0           0           0
            #           11:18        6:00           0           0           0           0           0           0
            #           13:27       11:18           0           0           0           0           0           0
            #           14:50       13:27           0           0           0           0           0           0
            #           15:53       14:50           0           0           0           0           0           0
            #           17:08       15:53           3       41880           0           0           0           0
            #           18:30       17:08           0           0           0           0           0           0
            #           19:38       18:30           0           0           0           0           0           0
            #        02:48:55         now          41      630258           0           1          21           5
            #      1:02:55:29    02:48:55         818     4115719          19         191        8777        7748

            #     Build times                  <= 1ms      <= 2ms      <= 5ms     <= 10ms     <= 20ms     <= 50ms    <= 100ms     > 100ms
            #            0:18         now           0           0           0           0           0           0           0           0
            #            1:18        0:18           0           0           0           0           0           0           0           0
            #            6:00        1:18           0           0           0           0           0           0           0           0
            #           11:18        6:00           0           0           0           0           0           0           0           0
            #           13:27       11:18           0           0           0           0           0           0           0           0
            #           14:50       13:27           0           0           0           0           0           0           0           0
            #           15:53       14:50           0           0           0           0           0           0           0           0
            #           17:08       15:53           3           0           0           0           0           0           0           0
            #           18:30       17:08           0           0           0           0           0           0           0           0
            #           19:38       18:30           0           0           0           0           0           0           0           0
            #        02:48:55         now          39           1           1           0           0           0           0           0
            #      1:02:55:29    02:48:55         723          16          21          44           8           5           0           1

            #     Use counters                   <= 1       <= 10      <= 100     <= 1000    <= 10000     > 10000
            #            0:18         now           0           0           0           0           0           0
            #            1:18        0:18           0           0           0           0           0           0
            #            6:00        1:18           0           0           0           0           0           0
            #           11:18        6:00           0           0           0           0           0           0
            #           13:27       11:18           0           0           0           0           0           0
            #           14:50       13:27           0           0           0           0           0           0
            #           15:53       14:50           0           0           0           0           0           0
            #           17:08       15:53           0           0           0           0           2           1
            #           18:30       17:08           0           0           0           0           0           0
            #           19:38       18:30           0           0           0           0           0           0
            #        02:48:55         now           0           2           4           8          15          12
            #      1:02:55:29    02:48:55          71         170         137         156         175         109
        }
        if ($lineEnumerator.Current.Contains('Protected broadcast actions:')) {
            # Protected broadcast actions:
            #   android.os.action.ACTION_EFFECTS_SUPPRESSOR_CHANGED
            #   android.provider.action.EXTERNAL_PROVIDER_CHANGE
            #   android.intent.action.SCREEN_OFF
            #   android.net.proxy.PAC_REFRESH
            #   android.hardware.usb.action.USB_DEVICE_ATTACHED
            #   com.android.ims.IMS_SERVICE_DOWN
            #   android.intent.action.SERVICE_STATE
            #   android.intent.action.ACTION_IDLE_MAINTENANCE_END
            #   android.accounts.action.ACCOUNT_REMOVED
            #   android.os.action.LOW_POWER_STANDBY_POLICY_CHANGED
            #   android.telecom.action.SHOW_MISSED_CALLS_NOTIFICATION
            #   android.bluetooth.device.action.NAME_FAILED
            #   android.bluetooth.action.CSIS_DEVICE_AVAILABLE
            #   android.intent.action.USER_REMOVED
            #   android.telephony.action.PRIMARY_SUBSCRIPTION_LIST_CHANGED
            #   android.nfc.handover.intent.action.HANDOVER_SEND_MULTIPLE
            #   android.intent.action.MEDIA_RESOURCE_GRANTED
            #   android.intent.action.PACKAGE_NEEDS_INTEGRITY_VERIFICATION
            #   android.intent.action.ACTION_SET_RADIO_CAPABILITY_FAILED
        }

        $output
    }
}



$script:PackagePattern = '[a-zA-Z0-9\._\-#]+'
$HashPattern = '[a-f0-9]+'
$ComponentClassNamePattern = '[a-zA-Z0-9\.\/_$]+'
# It seems this is possible: 'text/directory; profile=vcard:'
$MimeTypeHeaderPattern = '\s{6}[a-zA-Z*\d+_.\-/\s;=]+:'

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
    '\s{6}[\w..\-+?*]*:'
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

    #### This is another posibility of Database verions
    # Database versions:
    #   Internal:
    #     sdkVersion=35 databaseVersion=3
    #     buildFingerprint=google/husky/husky:15/BP1A.250505.005.B1/13277630:user/release-keys fingerprint=a18c8a2ab7519d77e1730574b264065914cc7b3f
    #   External:
    #     sdkVersion=34 databaseVersion=3
    #     buildFingerprint=google/husky/husky:14/AP1A.240305.019.A1/11445699:user/release-keys fingerprint=b0b103cd79fffaa0d00f9f61a1e6901d4d564efa

    # Known Packages:
    #   System:
    #     android
    #   Setup Wizard:
    #     com.google.android.setupwizard
    #   Installer:
    #     com.google.android.packageinstaller
    #   Uninstaller:
    #     com.google.android.packageinstaller
    #   Verifier:
    #     com.android.vending
    #   Browser:
    #     com.brave.browser
    #   System Text Classifier:
    #     com.google.android.ext.services
    #     com.google.android.as
    #   Permission Controller:
    #     com.google.android.permissioncontroller
    #   Wellbeing:
    #     none
    #   Documenter:
    #     none
    #   Configurator:
    #     com.google.android.gms
    #   Incident Report Approver:
    #     com.google.android.permissioncontroller
    #   App Predictor:
    #     com.google.android.as
    #   Overlay Config Signature:
    #     none
    #   Wi-Fi:
    #     none
    #   Companion:
    #     com.android.companiondevicemanager
    #   Retail Demo:
    #     com.google.android.retaildemo
    #   Recents:
    #     com.google.android.apps.nexuslauncher
    #   Ambient Context Detection:
    #     com.google.android.as
    #   Wearable sensing:
    #     none

    # Verifiers:
    #   Required: com.android.vending (uid=10147)

    # Domain Verifier:
    #   Using: com.google.android.gms (uid=10140)

    # Intent Filter Verifier:
    #   Using: com.google.android.gms (uid=10143)

    if ($LineEnumerator.Current.Contains('Database versions:')) {
        do {
            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
        while ($LineEnumerator.Current[0] -ceq ' ')
    }
    if ($LineEnumerator.Current.Contains('Known Packages:')) {
        do {
            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
        while ($LineEnumerator.Current[0] -ceq ' ')
    }
    if ($LineEnumerator.Current.Contains('Verifiers:')) {
        do {
            $LineEnumerator.MoveNextIgnoringBlank() > $null
        }
        while ($LineEnumerator.Current[0] -ceq ' ' -or $LineEnumerator.Current[$LineEnumerator.Current.Length - 1] -cne ':')
    }
    if ($LineEnumerator.Current.Contains('Domain Verifier:')) {
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
        $componentContainerName = $LineEnumerator.Current.Trim().Replace(':', '')
        $container = [PSCustomObject]@{
            Name = if ($componentContainerName) {
                $componentContainerName
            }
            else {
                ""
            }
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
                $attributeName = ConvertTo-CamelCase $attributeName
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
                $attributeName = ConvertTo-CamelCase $attributeName
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

        [string] $Name,

        [Parameter(Mandatory)]
        [PSCustomObject] $InputObject
    )

    $InputObject | Add-Member -MemberType NoteProperty -Name $Name -Value @()

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
                    $attributeName = ConvertTo-CamelCase $attributeName
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
