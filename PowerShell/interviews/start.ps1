function set-user {
    param(
        [parameter(valuefrompipelinebypropertyname = $true, mandatory = $true)]
        [ValidateSet("ram", "rava")]
        [string]$user
    )
    process {
        write-host "sets the user "

    }
}