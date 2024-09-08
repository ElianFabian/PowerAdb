function Remove-AdbSetting {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("Global", "System", "Secure")]
        [string] $Namespace
    )

    dynamicparam {
        if ($PSBoundParameters.ContainsKey('Namespace')) {
            $KeyAttribute = New-Object System.Management.Automation.ParameterAttribute
            $KeyAttribute.Mandatory = $true
            $KeyAttribute.HelpMessage = "Must specify Namespace first before setting Key"

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
        $DeviceId | Invoke-AdbExpression -Command "shell settings delete $namespaceLowercase $Key"
    }
}
