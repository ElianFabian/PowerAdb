function Send-AndroidNavigationGesture {

    param (
        [string] $DeviceId,

        [ValidateSet(
            'Left',
            'Right',
            'PredictiveLeft',
            'PredictiveRight'
        )]
        [string] $GestureType
    )

    $screenSize = Get-AdbScreenSize -DeviceId $DeviceId

    switch ($GestureType) {
        'Left' {
            $x1 = 0
            $y1 = $screenSize.Height / 2
            $x2 = $screenSize.Width * 0.1
            $y2 = $screenSize.Height / 2
            $time = 50
        }
        'Right' {
            $x1 = $screenSize.Width - 1
            $y1 = $screenSize.Height / 2
            $x2 = $screenSize.Width * 0.9
            $y2 = $screenSize.Height / 2
            $time = 50
        }
        'PredictiveLeft' {
            $x1 = 0
            $y1 = $screenSize.Height / 2
            $x2 = $screenSize.Width * 0.9
            $y2 = $screenSize.Height / 2
            $time = 500
        }
        'PredictiveRight' {
            $x1 = $screenSize.Width - 1
            $y1 = $screenSize.Height / 2
            $x2 = $screenSize.Width * 0.1
            $y2 = $screenSize.Height / 2
            $time = 500
        }
    }

    Send-AdbSwipe -DeviceId $DeviceId -X1 $x1 -Y1 $y1 -X2 $x2 -Y2 $y2 -DurationInMilliseconds $time
}
