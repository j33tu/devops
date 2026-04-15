function Test-LocalBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    begin {
        $sourcePath = "C:\Data\codes\devops\backup\$FileName"
        $backupPath = "C:\Data\codes\devops\backup\$FileName.bak"
        
        Write-Verbose "Initializing backup sequence for $FileName..."
    }

    process {
        # DEBUG: Let's check if the source actually exists before we try to copy
        Write-Debug "Checking path: $sourcePath. Does it exist? $(Test-Path $sourcePath)"

        if (Test-Path $sourcePath) {
            Write-Verbose "Source found. Creating backup at $backupPath"
            Copy-Item -Path $sourcePath -Destination $backupPath -Force
            Write-Host "Backup of $FileName completed successfully!" -ForegroundColor Green
        }
        else {
            Write-Debug "LOGIC FAILURE: Source path $sourcePath was not found. Skipping Copy."
            Write-Warning "Target file '$FileName' not found in C:\Data\codes\devops"
        }
    }
}