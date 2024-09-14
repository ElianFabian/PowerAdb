function Get-AdbProperty {

    [CmdletBinding(
        DefaultParameterSetName = "Default",
        SupportsShouldProcess = $false
    )]
    [OutputType([string[]], ParameterSetName = "Default")]
    [OutputType([PSCustomObject[]], ParameterSetName = "List")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [string[]] $Name,

        # Fast query of multiple values
        [Parameter(ParameterSetName = "Default")]
        [switch] $QueryFromList,

        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List
    )

    process {
        foreach ($id in $DeviceId) {
            if ($List) {
                Invoke-AdbExpression -DeviceId $id -Command 'shell getprop' `
                | Out-String `
                | Select-String -Pattern "\[(.+)\]: \[(.+)\]" -AllMatches `
                | Select-Object -ExpandProperty Matches `
                | ForEach-Object {
                    [PSCustomObject]@{
                        Name  = $_.Groups[1].Value
                        Value = $_.Groups[2].Value
                    }
                }
                continue
            }

            $values = if ($QueryFromList) {
                $properties = Get-AdbProperty -DeviceId $id -List -WhatIf:$false -Confirm:$false
                $targetProperties = foreach ($propName in $Name) {
                    $properties | Where-Object {
                        $_.Name -ceq $propName
                    } `
                    | Select-Object -First 1
                }

                $targetProperties | Where-Object { $_.Name -cin $Name } `
                | Select-Object -ExpandProperty Value
            }
            else {
                $Name | ForEach-Object {
                    if ($_.Contains(" ")) {
                        Write-Error "Property name '$_' can't contain space characters"
                        continue
                    }

                    Invoke-AdbExpression -DeviceId $id -Command "shell getprop '$Name'" -WhatIf:$false -Confirm:$false
                }
            }

            $values | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        }
    }
}
