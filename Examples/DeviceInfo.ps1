$properties = @(
    'ro.build.version.sdk' # API level
    'ro.product.locale'
    'persist.sys.locale'
    'persist.sys.language'
    'persist.sys.country'
    'ro.product.locale.language'
    'ro.product.locale.region'
    'ro.build.date.utc'
    'ro.product.product.brand'
    'ro.product.product.device'
    'ro.product.product.manufacturer'
    'ro.product.product.model'
    'ro.product.product.name'
    'ro.product.system.brand'
    'ro.product.system.device'
    'ro.product.system.manufacturer'
    'ro.product.system.model'
    'ro.product.system.name'
)


$globalSettings = @(
    'adb_wifi_enabled'
    'boot_count'
    'mobile_data'
    'private_dns_mode'
    'private_dns_specifier'
    'user_switcher_enabled'
    'wifi_on'
)

$systemSettings = @(
    'accelerometer_rotation'
    'font_scale'
    'pointer_location'
    'show_touches'
    'system_locales'
    'user_rotation'
)

$secureSettings = @(
    'location_mode'
    'location_mode_providers_allowed'
)
