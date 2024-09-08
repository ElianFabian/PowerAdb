function Get-AdbSetting {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("Global", "System", "Secure")]
        [string] $Namespace,

        # If any Key contains '=' then output will be wrong
        [Parameter(Mandatory, ParameterSetName = "List")]
        [switch] $List
    )

    dynamicparam {
        if ($PSBoundParameters.ContainsKey('Namespace')) {
            $KeyAttribute = New-Object System.Management.Automation.ParameterAttribute
            $KeyAttribute.Mandatory = $true
            $KeyAttribute.HelpMessage = "Must specify Namespace first before setting Key"
            $KeyAttribute.ParameterSetName = "Default"

            $Key = New-Object System.Management.Automation.RuntimeDefinedParameter('Key', [string], $KeyAttribute)
            $KeyDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $KeyDictionary.Add('Key', $Key)
            return $KeyDictionary
        }
    }

    begin {
        $Key = [string] $PSBoundParameters['Key']
        if ($Key.Contains(" ")) {
            Write-Error "Key '$Key' can't contain space characters"
            return
        }

        $namespaceLowercase = $Namespace.ToLower()
    }

    process {
        foreach ($id in $DeviceId) {
            if ($List) {
                Invoke-AdbExpression -DeviceId $id -Command "shell settings list $namespaceLowercase"
                | Out-String -Stream
                | ForEach-Object {
                    $indexOfEqualsSymbol = $_.IndexOf('=')
                    $itemKey = $_.Substring(0, $indexOfEqualsSymbol)
                    $itemValue = $_.Substring($indexOfEqualsSymbol + 1)
                    [PSCustomObject]@{
                        Key   = $itemKey
                        Value = $itemValue
                    }
                }
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell settings get $namespaceLowercase $Key"
        }
    }
}
