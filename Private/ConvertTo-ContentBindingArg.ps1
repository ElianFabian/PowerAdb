function ConvertTo-ContentBindingArg {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [object] $InputObject
    )

    return $InputObject.PSObject.Properties `
    | Where-Object { $_.MemberType -eq 'NoteProperty' } `
    | ForEach-Object {
        $type = $_.Value.GetType().Name

        $entryType = if ($null -eq $_.Value) {
            'n'
        }
        else {
            switch ($type) {
                'Boolean' { 'b' }
                'String' { 's' }
                'Int32' { 'i' }
                'Int64' { 'l' }
                'Single' { 'f' }
                'Double' { 'd' }
                default { 's' }
            }
        }

        $sanitizedValue = $_.Value
        if ($type -eq 'Single' -or $type -eq 'Double') {
            $sanitizedValue = $sanitizedValue.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        }
        elseif ($type -eq 'Boolean') {
            $sanitizedValue = if ($sanitizedValue) { 'true' } else { 'false' }
        }

        $entry = "$($_.Name):$entryType`:$($_.Value)"
        $sanitizedEntry = ConvertTo-ValidAdbStringArgument $entry

        " --bind $sanitizedEntry"
    }
}
