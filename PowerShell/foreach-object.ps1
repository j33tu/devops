$numbers = 1..10
$sqresult = [System.Collections.Generic.list[object]]::new()
$numbers | foreach-object {
    $ob = [PSCustomObject]@{
        Number = $_
        square = $_ * $_
    }
    $sqresult.Add($ob)
}

$sqresult