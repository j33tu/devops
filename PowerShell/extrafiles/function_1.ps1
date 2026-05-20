function clear_pathfile{
[cmdletbinding()]
param(
     [parameter(mandatory=$True)]
     [string]$pathname,
     [parameter(mandatory=$True)]
     [System.Security.SecureString]$daysold
     
)

process {

$cutoffdate=(Get-Date).AddDays(-$daysold)
$files=Get-ChildItem -Path $pathname -filter *.dll  | where{$_.LastWriteTime -lt $cutoffdate}

try{

foreach($file in $files){
write-host "deleting all files under path " -ForegroundColor Green
Remove-Item $file -Force
}
}

catch{

write-host "failed to delete items " -ForegroundColor Red

}

finally {
write-host " no more files are older than $daysold in directory " -ForegroundColor Yellow
}

}
}