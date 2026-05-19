function Get-SystemPressure {
    $Queue = (Get-CimInstance Win32_PerfFormattedData_PerfOS_System).ProcessorQueueLength
    return $Queue
}