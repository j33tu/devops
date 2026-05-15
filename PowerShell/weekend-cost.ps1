# Pull compute cost for last weekend
$startDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
$endDate = (Get-Date).ToString("yyyy-MM-dd")

Get-AzConsumptionUsageDetail `
    -StartDate $startDate `
    -EndDate $endDate |
Where-Object {
    $_.ConsumedService -eq "Microsoft.Compute" -and
    $_.DayOfWeek -in @("Saturday", "Sunday")
} |
Group-Object InstanceName |
Select-Object Name,
@{N = "TotalCost"; E = { ($_.Group | Measure-Object PretaxCost -Sum).Sum } } |
Sort-Object TotalCost -Descending