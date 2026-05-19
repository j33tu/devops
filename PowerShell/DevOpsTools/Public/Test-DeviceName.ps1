function Test-DeviceName {
    param([string]$ComputerName)
    if ($ComputerName -like "WN-*") { return $true }
    return $false
}