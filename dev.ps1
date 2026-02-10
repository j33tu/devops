$groups = @(
    "rg-dev1-applications",
    "rg-dev2-applications",
    "rg-prod-networking",
    "rg-dev-applications",
    "rg-prod-applications",
    "rg-g2-applications"
)

foreach ($rg in $groups) {
    Write-Host "Starting deletion of $rg..."
    Remove-AzResourceGroup -Name $rg -Force -AsJob
}

Write-Host "Deletion jobs submitted. Check progress with 'Get-Job'."