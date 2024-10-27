function Invoke-AdbDeepLink {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $ApplicationId,

        [Parameter(Mandatory)]
        [string] $Uri
    )

    process {
        # TODO: maybe we could make this more flexible or maybe it doesn't make sense to use
        # Or even we could define a more generic way to use Activity Manager
        $DeviceId `
        | Invoke-AdbExpression -Command "shell am start -a android.intent.action.VIEW -d '$Uri' '$ApplicationId'" -Verbose:$VerbosePreference > $null
    }
}
