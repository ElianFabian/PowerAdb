function Invoke-AdbDeepLink {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $ApplicationId,

        [Parameter(Mandatory)]
        [string] $Uri
    )

    process {
        # TODO: maybe we could make this more flexible or maybe it doesn't make sense to use
        # the '--activity-single-top' in every case (it's here because it allows to always open the deep-link)
        # Or even we could define a more generic function that allows to start any kind of component with a custom intent
        $DeviceId | Invoke-AdbExpression -Command "shell am start -a android.intent.action.VIEW -d '$Uri' '$ApplicationId' --activity-single-top" > $null
    }
}
