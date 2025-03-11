function Get-AdbScreenPixel {
    # https://stackoverflow.com/questions/24185005/how-can-i-get-the-color-of-a-screen-pixel-through-adb

    [OutputType(ParameterSetName = 'AsPixel', [PSCustomObject])]
    [OutputType(ParameterSetName = 'AsByteArray', [byte[]])]
    [CmdletBinding(DefaultParameterSetName = 'AsPixel')]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(ParameterSetName = 'AsByteArray')]
        [switch] $AsByteArray
    )

    $tempFilename = (New-Guid).Guid
    $remoteTempFilePath = "/data/local/tmp/$tempFilename"
    $localTempFilePath = "$env:TEMP/$tempFilename"

    foreach ($id in $DeviceId) {
        try {
            $screenSize = Get-AdbScreenSize -DeviceId $id -Verbose:$false

            Invoke-AdbExpression -DeviceId $id -Command "shell screencap '$remoteTempFilePath'" -Verbose:$VerbosePreference -Confirm:$false -WhatIf:$false
            Receive-AdbItem -DeviceId $id -LiteralRemotePath $remoteTempFilePath -LiteralLocalPath $localTempFilePath -Force -Verbose:$VerbosePreference -Confirm:$false -WhatIf:$false *> $null

            $imageBytesCount = (Get-Item $localTempFilePath).Length

            $stream = [System.IO.File]::Open($localTempFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
            $reader = [System.IO.BinaryReader]::new($stream)

            $imageBytesWithoutHeaderCount = $screenSize.Width * $screenSize.Height * 4

            # The header of the image is not the same size in all Android versions.
            $bytesToSkip = $imageBytesCount - $imageBytesWithoutHeaderCount

            $stream.Seek($bytesToSkip, [System.IO.SeekOrigin]::Current) > $null

            if ($AsByteArray) {
                $reader.ReadBytes($imageBytesWithoutHeaderCount)
            }
            else {                
                $screenPixels = [PSCustomObject]@{
                    DeviceId = $id
                    Width    = $screenSize.Width
                    Height   = $screenSize.Height
                    Bytes    = $reader.ReadBytes($imageBytesWithoutHeaderCount)
                }

                $screenPixels | Add-Member -MemberType ScriptMethod -Name 'GetPixel' -Value {

                    param (
                        [int] $x,
                        [int] $y
                    )

                    if ($x -lt 0 -or $x -ge $this.Width) {
                        throw "The X coordinate must be between 0 and $($this.Width - 1)."
                    }
                    if ($y -lt 0 -or $y -ge $this.Height) {
                        throw "The Y coordinate must be between 0 and $($this.Height - 1)."
                    }

                    $index = ($this.Width * $y + $x) * 4
                    $red = $this.Bytes[$index]
                    $green = $this.Bytes[$index + 1]
                    $blue = $this.Bytes[$index + 2]
                    $alpha = $this.Bytes[$index + 3]

                    $pixel = [PSCustomObject] @{
                        IntValue = ([int] $alpha -shl 24) -bor ([int] $red -shl 16) -bor ([int] $green -shl 8) -bor [int] $blue
                    }

                    $pixel | Add-Member -MemberType ScriptProperty -Name 'HexValue' -Value {
                        "#" + $this.IntValue.ToString('X8')
                    }

                    $pixel | Add-Member -MemberType ScriptProperty -Name 'Color' -Value {
                        return [PSCustomObject]@{
                            Alpha = [int] ([uint32]::CreateTruncating($this.IntValue -shr 24) -band 0xFF)
                            Red   = [int] ([uint32]::CreateTruncating($this.IntValue -shr 16) -band 0xFF)
                            Green = [int] ([uint32]::CreateTruncating($this.IntValue -shr 8) -band 0xFF)
                            Blue  = $this.IntValue -band 0xFF
                        }
                    }

                    $pixel
                }

                $screenPixels
            }
        }
        finally {
            $reader.Close()
            $stream.Close()
        }
    }
}
