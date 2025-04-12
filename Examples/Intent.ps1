$Intent = [PSCustomObject]@{
    Action = [PSCustomObject]@{
        Main = 'android.intent.action.MAIN'
        View = 'android.intent.action.VIEW'
    }
    Category = [PSCustomObject]@{
        Default = 'android.intent.category.DEFAULT'
        Browsable = 'android.intent.category.BROWSABLE'
    }
}
