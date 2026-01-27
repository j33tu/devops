# 1. Configuration
$TargetEmail = "jeetu12iu@gmail.com"
$GmailUser   = "jeetu12iu@gmail.com"  # Your sending Gmail address
$AppPassword = "qusp vsou dqag vnsg"   # The 16-character App Password

# 2. Fetch Data and Store in a Hashtable
$ServiceData = @{} # Initialize empty hashtable
$TargetServices = "WinRM", "Spooler", "W32Time" # List of services to check

foreach ($SvcName in $TargetServices) {
    $Service = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
    
    if ($Service) {
        # Store Service Name as Key and Status as Value
        $ServiceData[$SvcName] = $Service.Status
    } else {
        $ServiceData[$SvcName] = "Not Found"
    }
}

# 3. Convert Hashtable to a readable String/HTML for the email
$MailBody = "<h3>System Service Report</h3><table border='1' style='border-collapse: collapse;'>"
$MailBody += "<tr><th>Service Name</th><th>Status</th></tr>"

foreach ($Key in $ServiceData.Keys) {
    $MailBody += "<tr><td>$Key</td><td>$($ServiceData[$Key])</td></tr>"
}
$MailBody += "</table>"

# 4. Email Setup (using Splatting for clean code)
$SecurePassword = $AppPassword | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($GmailUser, $SecurePassword)

$MailParams = @{
    From       = $GmailUser
    To         = $TargetEmail
    Subject    = "System Requirement Report - $(Get-Date -Format 'yyyy-MM-dd')"
    Body       = $MailBody
    BodyAsHtml = $true
    SmtpServer = "smtp.gmail.com"
    Port       = 587
    UseSsl     = $true
    Credential = $Credential
}

# 5. Send the Mail
Write-Host "Sending report to $TargetEmail..."
Send-MailMessage @MailParams
Write-Host "Done!"