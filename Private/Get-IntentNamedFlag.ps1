function Get-IntentNamedFlag {

    param (
        [int] $ApiLevel
    )

    if ($ApiLevel -lt 16) {
        return
    }

    if ($ApiLevel -ge 16) {
       'grant-read-uri-permission'
       'grant-write-uri-permission'
       'debug-log-resolution'
       'exclude-stopped-packages'
       'include-stopped-packages'
       'activity-brought-to-front'
       'activity-clear-top'
       'activity-clear-when-task-reset'
       'activity-exclude-from-recents'
       'activity-launched-from-history'
       'activity-multiple-task'
       'activity-no-animation'
       'activity-no-history'
       'activity-no-user-action'
       'activity-previous-is-top'
       'activity-reorder-to-front'
       'activity-reset-task-if-needed'
       'activity-single-top'
       'activity-clear-task'
       'activity-task-on-home'
       'receiver-registered-only'
       'receiver-replace-pending'
    }
    if ($ApiLevel -ge 21) {
        'grant-persistable-uri-permission'
        'grant-prefix-uri-permission'
    }
    if ($ApiLevel -ge 24) {
        'receiver-foreground'
    }
    if ($ApiLevel -ge 26) {
        'receiver-no-abort'
        'receiver-include-background'
    }
    if ($ApiLevel -ge 28) {
        'activity-match-external'
    }
}
