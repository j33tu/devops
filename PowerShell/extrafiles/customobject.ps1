$data = [System.Collections.Generic.list[System.Object]]::new()
$myimage = [PSCustomObject]@{
    template = "windows-golden"
    version  = "1.0"
    author   = "goldvm"
    status   = "inprogress"
}
$myimage2 = [PSCustomObject]@{
    template = "windows-golden2"
    version  = "2.0"
    author   = "goldvm2"
    status   = "deployed"
}
$data.Add($myimage)
$data.Add($myimage2)
$data