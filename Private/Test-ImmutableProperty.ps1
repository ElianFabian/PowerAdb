function Test-ImmutableProperty {

    param (
        [Parameter(Mandatory)]
        [string] $Name
    )

    # TODO: Test it on multiple devices

    if ($Name.StartsWith('debug.')) {
        return $false
    }
    if ($Name.StartsWith('log.tag.')) {
        return $false
    }
    if ($Name.StartsWith('persist.log.tag.')) {
        return $false
    }
    if ($Name.StartsWith('persist.tranced.')) {
        return $false
    }
    if ($Name.StartsWith('security.')) {
        return $false
    }

    return $true
}
