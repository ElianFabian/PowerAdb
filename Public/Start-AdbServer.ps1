function Start-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    if ($PSCmdlet.ShouldProcess("adb start-server", '', 'Start-AdbServer')) {
        adb start-server
    }
}
