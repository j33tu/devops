# Define the possible values
$regions = "East US", "West US", "South India", "Southeast Asia", "UK South"
$statuses = "Online", "Offline"

# Create the collection
$data = 1..200 | ForEach-Object {
    [PSCustomObject]@{
        ServerName  = "SRV-$((100..999 | Get-Random))"
        IPAddress   = "10.10.$((1..254 | Get-Random)).$((1..254 | Get-Random))"
        Status      = $statuses | Get-Random
        AzureRegion = $regions | Get-Random
    }
}

# Export to CSV in your current directory
$data | Export-Csv -Path ".\ServerInventory.csv" -NoTypeInformation

Write-Host "CSV Created at: $((Get-Item .\ServerInventory.csv).FullName)" -ForegroundColor Cyan