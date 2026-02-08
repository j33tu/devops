$result = get-service | Select-Object Name,status,starttype |where{$_.StartType -eq "manual"-and $_.Status -eq "stopped"} 
$result | Export-Csv -path C:\temp\service.csv -NoTypeInformation -Force