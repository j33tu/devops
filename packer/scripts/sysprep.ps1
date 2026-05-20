Write-Host "Running Sysprep..."

$sysprepPath = "C:\Windows\System32\Sysprep\Sysprep.exe"

Start-Process $sysprepPath -ArgumentList "/oobe /generalize /shutdown /quiet" -Wait

Write-Host "Sysprep completed"