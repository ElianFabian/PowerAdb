function Get-AdbProcess {

    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [int[]] $Id
    )

    if ($Id) {
        $idArg = " -p $($Id -join ',')"
    }

    $rawProcesses = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell ps$idArg" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
    | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    $header = $rawProcesses | Select-Object -First 1
    $processes = $rawProcesses | Select-Object -Skip 1

    $programCounterOrKernelAddressField = if ($header.Contains('PC')) {
        'ProgramCounter'
    }
    elseif ($header.Contains('ADDR')) {
        'KernelAddress'
    }
    else {
        'Unknown'
    }

    # TODO: I could use the original field names, it would make the code shorter and maybe
    # people are more used to those names

    if ($processes) {
        $processes | ForEach-Object {
            $output = [PSCustomObject]@{
                RawContent = $_
            }

            $output | Add-Member -MemberType ScriptProperty -Name Properties -Value {
                $fields = $this.RawContent -split '\s+' | Where-Object { $_ }

                $user = $fields[0]
                $processId = $fields[1]
                $parentId = $fields[2]
                $virtualMemorySize = $fields[3]
                $residentSetSize = $fields[4]
                $waitingChannel = $fields[5]
                $programCounterOrKernelAddress = $fields[6]
                $state = $fields[7]
                $processName = $fields[8]

                $properties = [PSCustomObject]@{
                    User              = $user
                    Id                = $processId
                    ParentId          = $parentId
                    VirtualMemorySize = $virtualMemorySize
                    ResidentSetSize   = $residentSetSize
                    WaitingChannel    = $waitingChannel
                    State             = $state
                    Name              = $processName
                }

                $properties | Add-Member -MemberType NoteProperty -Name $programCounterOrKernelAddressField -Value $programCounterOrKernelAddress

                $properties
            }.GetNewClosure()

            $output
        }
    }
}
