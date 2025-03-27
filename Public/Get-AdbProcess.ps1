function Get-AdbProcess {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [int[]] $Id
    )

    process {
        foreach ($device in $DeviceId) {
            if ($Id) {
                $idArg = " -p $($Id -join ',')"
            }

            $rawProcesses = Invoke-AdbExpression -DeviceId $device -Command "shell ps$idArg" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
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

            if ($processes) {
                $processes | ForEach-Object {
                    $output = [PSCustomObject]@{
                        DeviceId   = $device
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
                            ProcessName       = $processName
                        }

                        $properties | Add-Member -MemberType NoteProperty -Name $programCounterOrKernelAddressField -Value $programCounterOrKernelAddress

                        $properties
                    }.GetNewClosure()

                    $output
                }
            }
        }
    }
}
