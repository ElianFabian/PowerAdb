function Stop-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    if ($PSCmdlet.ShouldProcess("adb kill-server", '', 'Stop-AdbServer')) {
        adb kill-server
    }
}
