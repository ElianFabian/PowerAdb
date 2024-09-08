function Get-AdbProp {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([string[]], ParameterSetName = "Default")]
    [OutputType([PSCustomObject[]], ParameterSetName = "List")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [string[]] $PropertyName,

        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List
    )

    process {
        foreach ($id in $DeviceId) {
            if ($List) {
                Invoke-AdbExpression -DeviceId $id -Command "shell getprop" `
                | Out-String `
                | Select-String -Pattern "\[(.+)\]: \[(.+)\]" -AllMatches `
                | Select-Object -ExpandProperty Matches `
                | ForEach-Object {
                    [PSCustomObject]@{
                        Property = $_.Groups[1].Value
                        Value    = $_.Groups[2].Value
                    }
                }
                continue
            }

            $PropertyName | ForEach-Object {
                if ($_.Contains(" ")) {
                    Write-Error "PropertyName '$_' can't contain space characters"
                    continue
                }

                Invoke-AdbExpression -DeviceId $id -Command "shell getprop $PropertyName"
            } `
            | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        }
    }
}
