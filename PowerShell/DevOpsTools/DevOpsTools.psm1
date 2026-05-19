# =====================================================================
# DevOpsTools.psm1 (Self-Healing / Dynamic Version)
# =====================================================================

# 1. Dynamically target and index all individual function scripts
$PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"

foreach ($File in $PublicFunctions) {
    try {
        # Pull the logic out of the file layout into module memory space
        . $File.FullName
    }
    catch {
        Write-Warning "Failed to dot-source module file: $($File.Name). Reason: $_"
    }
}

# 2. AUTOMATICALLY EXTRACT FUNCTION NAMES
# .BaseName automatically strips the ".ps1" extension off the filenames
$DynamicExports = $PublicFunctions.BaseName

# 3. EXPORT CLEANLY
# This passes the parsed array instantly, eliminating manual entry typos entirely!
Export-ModuleMember -Function $DynamicExports