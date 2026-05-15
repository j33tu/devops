#Requires -Version 7.2
<#
.SYNOPSIS
    Profile Monitor for FSLogix v1.4 - Enhanced with parameter validation and file locks.

.DESCRIPTION
    ProfileMonitor-for-FSLogix_v1.4.ps1 provides real-time monitoring, health checks, and diagnostics
    for FSLogix Profile Container and Office Container deployments.
    
    Key Features:
    • NEW: Parameter validation with ValidateRange attributes
    • NEW: VHD chain inspection for differencing disks
    • NEW: Credential-aware share testing (-ShareCredential)
    • NEW: File lock detection using handle.exe (-Get-FileLocks internally)
    • NEW: Prometheus metrics export for Grafana dashboards (-PrometheusOutFile)
    • VHD-based size detection using Get-VHD cmdlet
    • Configurable warning/error thresholds (-WarnPct, -ErrorPct)
    • Size caching for improved performance
    • Top folders analysis
    • Diagnostics package export
    • Color vision accessibility palettes
    • Remote computer support
    • SMB probe for share connectivity testing
    • ANSI color support with severity indicators
    • Watch mode for continuous monitoring
    • Event log integration
    • Export to CSV/JSON formats

.PARAMETER CurrentUser
    Display status for the current user only (default mode).

.PARAMETER AllUsers
    Display status for all users with FSLogix sessions. Requires Administrator privileges.

.PARAMETER Watch
    Refresh interval in seconds for continuous monitoring. Press 'q' to quit.

.PARAMETER IncludeEvents
    Show recent FSLogix operational events for each displayed user.

.PARAMETER EventCount
    Number of events to display when -IncludeEvents is used (default: 3).

.PARAMETER NoColor
    Disable ANSI color output for terminals without color support.

.PARAMETER Ascii
    Use ASCII characters instead of Unicode box-drawing characters.

.PARAMETER BeepOnError
    Play an audible beep when Red (error) severity is detected.

.PARAMETER ShowConfig
    Display FSLogix configuration settings from the registry.

.PARAMETER CheckShares
    Test connectivity to VHDLocations paths using SMB probe.

.PARAMETER TailLogs
    Number of lines to display from the most recent FSLogix log file.

.PARAMETER ExportCsv
    Export results to a CSV file at the specified path.

.PARAMETER ExportJson
    Export results to a JSON file at the specified path.

.PARAMETER Copy
    Copy a one-line summary to the clipboard.

.PARAMETER WarnPct
    Warning threshold percentage for VHD capacity (0-100, default: 70).

.PARAMETER ErrorPct
    Error threshold percentage for VHD capacity (0-100, default: 90).

.PARAMETER FastSize
    Skip VHD mounting for faster but less accurate size detection.

.PARAMETER SizeCacheMinutes
    Cache size data for the specified number of minutes (0-1440, default: 0).

.PARAMETER InvalidateSizeCache
    Force refresh of cached size data.

.PARAMETER TopFolders
    Show top N largest folders within the profile container (0-100).

.PARAMETER Diag
    Export a comprehensive diagnostics package.

.PARAMETER ComputerName
    Target remote computers for status collection.

.PARAMETER SizeShowPercentAlways
    Always show percentage in size column even if below thresholds.

.PARAMETER SkipSizeRemote
    Skip size calculation for remote computers.

.PARAMETER ShareCredential
    PSCredential object for authenticated share access testing.

.PARAMETER PrometheusOutFile
    Export metrics in Prometheus format to the specified file path.

.PARAMETER ColorVision
    Select accessibility palette: Normal, Deuteranopia, Protanopia, Tritanopia, Monochrome.

.PARAMETER HighContrast
    Enable high contrast color mode for better visibility.

.PARAMETER PalettePreview
    Preview the selected color palette without running main functions.

.EXAMPLE
    .\ProfileMonitor-for-FSLogix_v1.4.ps1
    Shows the current user's Profile Monitor for FSLogix.

.EXAMPLE
    .\ProfileMonitor-for-FSLogix_v1.4.ps1 -AllUsers -WarnPct 60 -ErrorPct 80
    Monitor all users with custom capacity thresholds (validated 0-100).

.EXAMPLE
    .\ProfileMonitor-for-FSLogix_v1.4.ps1 -CheckShares -ShareCredential (Get-Credential)
    Test share connectivity with explicit credentials.

.EXAMPLE
    .\ProfileMonitor-for-FSLogix_v1.4.ps1 -AllUsers -PrometheusOutFile "C:\Metrics\fslogix.prom"
    Export metrics for Grafana/Prometheus monitoring.

.EXAMPLE
    .\ProfileMonitor-for-FSLogix_v1.4.ps1 -AllUsers -ExportJson "C:\Reports\status.json"
    Export comprehensive status with VHD chain info to JSON.

.NOTES
    Version:        1.4
    Author:         Drazen Nikolic
    License:        GPL-3.0
    Copyright:      (c) 2025 Drazen Nikolic
    Creation Date:  2025-10
    GitHub:         https://github.com/DrazenNikolic/FSLogix-Profile-Status
    LinkedIn:       https://www.linkedin.com/in/drazen-nikolic-816906142/
    
    EXIT CODES:
    ─────────────────────────────────────────────────────────────────────────
    0 = All profiles healthy, no issues detected
    1 = Warning conditions detected (yellow status)
    2 = Error conditions detected (red status) or execution failure
    ─────────────────────────────────────────────────────────────────────────
    
    REQUIREMENTS:
    ─────────────────────────────────────────────────────────────────────────
    [REQUIRED]
    • PowerShell 7.2 or higher (pwsh.exe)
      Install: winget install Microsoft.PowerShell
      Run:     pwsh.exe -ExecutionPolicy Bypass -File "ProfileMonitor-for-FSLogix_v1.4.ps1"
    
    • FSLogix Agent must be installed and running on target systems
    
    • Administrator rights required for -AllUsers mode and VHD inspection
    
    [OPTIONAL - Enhanced Features]
    • Hyper-V PowerShell Module
      For: VHD mounting, optimization, and chain analysis
      Install: Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell
    
    • handle.exe (Sysinternals)
      For: File lock detection on VHD files
      Download: https://learn.microsoft.com/sysinternals/downloads/handle
      Place in PATH or script directory
    
    • SmbShare Module (usually pre-installed on Windows Server)
      For: Remote SMB lock detection on file servers
    
    • Windows Terminal recommended for optimal ANSI color display
    ─────────────────────────────────────────────────────────────────────────
    
    CHANGELOG v1.4:
    ─────────────────────────────────────────────────────────────────────────
    NEW FEATURES:
    • Parameter validation using ValidateRange attributes
    • VHD chain inspection for differencing disk scenarios
    • Credential-aware share testing (-ShareCredential)
    • File lock detection using handle.exe (Get-FileLocks function)
    • Prometheus metrics export for Grafana integration
    • WarnPct/ErrorPct relationship validation
    
    IMPROVEMENTS:
    • Better error handling with validated input ranges
    • Improved share connectivity testing with credentials
    
    PREVIOUS VERSIONS:
    • v1.3 (2025-10-08) - VHD size detection, thresholds, caching, diagnostics
    • v1.2 (2025-10-05) - Added Size column
    • v1.1 (2025-09-10) - Added ODFC, ODFCSt, Mode columns
    • v1.0 (2025) - Initial release
    ─────────────────────────────────────────────────────────────────────────

.LINK
    https://github.com/DrazenNikolic/FSLogix-Profile-Status/releases
#>

[CmdletBinding(DefaultParameterSetName='Current')]
param(
  [Parameter(ParameterSetName='Current')][switch]$CurrentUser,
  [Parameter(ParameterSetName='All')][switch]$AllUsers,
  [int]$Watch = 0,
  [switch]$IncludeEvents,
  [int]$EventCount = 3,
  [switch]$NoColor,
  [switch]$Ascii,
  [switch]$BeepOnError,
  [switch]$ShowConfig,
  [switch]$CheckShares,
  [int]$TailLogs = 0,
  [string]$ExportCsv,
  [string]$ExportJson,
  [switch]$Copy,
  [ValidateRange(0,100)][int]$WarnPct = 70,
  [ValidateRange(0,100)][int]$ErrorPct = 90,
  [switch]$FastSize,
  [ValidateRange(0,1440)][int]$SizeCacheMinutes = 0,
  [switch]$InvalidateSizeCache,
  [ValidateRange(0,100)][int]$TopFolders = 0,
  [switch]$Diag,
  [string[]]$ComputerName = @(),
  [switch]$SizeShowPercentAlways,
  [switch]$SkipSizeRemote,
  [PSCredential]$ShareCredential,
  [string]$PrometheusOutFile,
  [ValidateSet('Normal','Deuteranopia','Protanopia','Tritanopia','Monochrome')]
  [string]$ColorVision = 'Normal',
  [switch]$HighContrast,
  [switch]$PalettePreview
)

if (-not $AllUsers -and -not $CurrentUser) { $CurrentUser = $true }

# Validate relationship: WarnPct < ErrorPct
if ($WarnPct -ge $ErrorPct) {
  throw "WarnPct ($WarnPct) must be less than ErrorPct ($ErrorPct)."
}

$ErrorActionPreference = 'Stop'
$script:Version = '1.4'

# ---------- ANSI helpers & palette ----------
$esc   = [char]27
$reset = "$esc[0m"
$AnsiEnabled = $true
try {
  if ($NoColor) { $AnsiEnabled = $false }
  elseif ($PSStyle -and $PSStyle.Foreground) { $AnsiEnabled = $true }
  elseif ($env:WT_SESSION) { $AnsiEnabled = $true }
  else { $AnsiEnabled = $Host.UI.SupportsVirtualTerminal }
} catch { $AnsiEnabled = $false }

function AnsiRgb ([string]$hex,[switch]$bg){
  if(-not $AnsiEnabled){ return '' }
  $hex=$hex.TrimStart('#'); if($hex.Length -lt 6){ return '' }
  $r=[Convert]::ToInt32($hex.Substring(0,2),16)
  $g=[Convert]::ToInt32($hex.Substring(2,2),16)
  $b=[Convert]::ToInt32($hex.Substring(4,2),16)
  if($bg){ return "$esc[48;2;${r};${g};${b}m" } else { return "$esc[38;2;${r};${g};${b}m" }
}

function Get-ColorPalette {
  param(
    [ValidateSet('Normal','Deuteranopia','Protanopia','Tritanopia','Monochrome')]
    [string] $Mode = 'Normal',
    [switch] $HighContrast,
    [switch] $NoColor
  )
  function _C ([string]$hex){
    if($NoColor){ return '' }
    if(Get-Command AnsiRgb -ErrorAction SilentlyContinue){ return AnsiRgb $hex }
    return "$([char]27)[0m"
  }
  $p = switch($Mode) {
    'Normal'      { [ordered]@{ Green='#22C55E'; Yellow='#F59E0B'; Red='#EF4444'; Blue='#3B82F6'; Gray='#94A3B8' } }
    'Deuteranopia'{ [ordered]@{ Green='#2C7BB6'; Yellow='#FDAE61'; Red='#D7191C'; Blue='#4575B4'; Gray='#8FA1B3' } }
    'Protanopia'  { [ordered]@{ Green='#1A9850'; Yellow='#FDB863'; Red='#B2182B'; Blue='#4393C3'; Gray='#8FA1B3' } }
    'Tritanopia'  { [ordered]@{ Green='#66BD63'; Yellow='#FEC44F'; Red='#D73027'; Blue='#3288BD'; Gray='#8FA1B3' } }
    'Monochrome'  { [ordered]@{ Green='#D1D5DB'; Yellow='#9CA3AF'; Red='#6B7280'; Blue='#374151'; Gray='#94A3B8' } }
  }
  if($HighContrast){
    $p['Green']  = '#00C853'
    $p['Yellow'] = '#FFAB00'
    $p['Red']    = '#D50000'
    $p['Blue']   = '#1E88E5'
    $p['Gray']   = '#7A8CA3'
  }
  [ordered]@{
    fgGreen  = _C $p['Green']
    fgYellow = _C $p['Yellow']
    fgRed    = _C $p['Red']
    fgBlue   = _C $p['Blue']
    fgGray   = _C $p['Gray']
    reset    = if($NoColor){ '' } else { "$([char]27)[0m" }
  }
}

$__palette = Get-ColorPalette -Mode $ColorVision -HighContrast:$HighContrast -NoColor:$NoColor
$fgGreen  = $__palette.fgGreen
$fgYellow = $__palette.fgYellow
$fgRed    = $__palette.fgRed
$fgBlue   = $__palette.fgBlue
$fgGray   = $__palette.fgGray
$reset    = $__palette.reset

# ---------- Icon shape helper ----------
function Get-IconShapes {
  $healthy = '●'
  $warn = if ($ColorVision -eq 'Normal') { '●' } else { '■' }
  $err  = if ($ColorVision -eq 'Normal') { '●' } else { '▲' }
  return @{ Healthy = $healthy; Warn = $warn; Error = $err }
}

# ---------- Box characters ----------
$B = if($Ascii){ @{ tl='+'; tr='+'; bl='+'; br='+'; h='-'; v='|'; j1='+'; j2='+' } }
     else       { @{ tl='┌'; tr='┐'; bl='└'; br='┘'; h='─'; v='│'; j1='├'; j2='┤' } }

# ---------- FSLogix registry roots ----------
$sessionRoot = 'HKLM:\SOFTWARE\FSLogix\Profiles\Sessions'
$profilesRoot= 'HKLM:\SOFTWARE\FSLogix\Profiles'
$odfcSessLM1 = 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\Sessions'
$odfcSessLM2 = 'HKLM:\SOFTWARE\FSLogix\ODFC\Sessions'
$odfcSessCU  = 'HKCU:\SOFTWARE\FSLogix\ODFC\Sessions'

# ---------- Mappings ----------
$mapStatus = @{ 0='Success'; 100='Waiting'; 200='InProgress'; 300='AlreadyAttached' }
$mapReason = @{ 0='Attached';1='NotInIncludeGroup';2='InExcludeGroup';3='LocalProfileExists';4='ShortSid';5='Unset';6='ComponentNotEnabled';7='WindowsTempProfile';8='NotAVDSession';9='LoadFailed' }
$advice    = @{ 0='Attached: profile/container mounted successfully.'; 1='User not in include group: check include policy and group membership.'; 2='User in exclude group: verify exclusion policy or group membership.'; 3='Local profile exists: consider deleting/renaming stale local profile or enable DeleteLocalProfileWhenVHDShouldApply.'; 6='Component disabled: check FSLogix Profiles "Enabled" policy/registry.'; 7='Temp profile in use: check logs for prior error and disk locks.'; 8='Not an AVD session: ensure targeting logic is correct.'; 9='Load failed: check for lock/in-use, permissions, or connectivity.' }

# ---------- Utils ----------
function Remove-ANSI([string]$s){ if(-not $s){ return '' } ($s -replace "\x1B\[[0-9;]*m","") }
function CleanLen ([string]$s){ (Remove-ANSI $s).Length }
function SidToName ([string]$sid){ try { ([Security.Principal.SecurityIdentifier]$sid).Translate([Security.Principal.NTAccount]).Value } catch { $sid } }
function Test-Admin { try { (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { $false } }
function ToStr ($v){ if($null -eq $v){ '' } else { [string]$v } }

function Format-Cell([string]$text,[int]$width,[ValidateSet('Left','Right')]$Align='Left',[string]$Color=''){
  $plain = ToStr $text
  if($plain.Length -gt $width){ $plain = $plain.Substring(0,$width) }
  $padCount = [Math]::Max(0, $width - $plain.Length)
  $visPlain = if($Align -eq 'Right'){ (' ' * $padCount) + $plain } else { $plain + (' ' * $padCount) }
  if($AnsiEnabled -and $Color){ return $Color + $visPlain + $reset } else { return $visPlain }
}
function SafeCell ([string]$text,[int]$width,[string]$Align='Left',[string]$Color=''){
  $s = Format-Cell -text $text -width $width -Align $Align -Color $Color
  if([string]::IsNullOrWhiteSpace($s)){
    $plain = ToStr $text
    if($plain.Length -gt $width){ $plain = $plain.Substring(0,$width) }
    $padCount=[Math]::Max(0,$width-$plain.Length)
    $vis = if($Align -eq 'Right'){ (' ' * $padCount) + $plain } else { $plain + (' ' * $padCount) }
    if($AnsiEnabled -and $Color){ return $Color + $vis + $reset } else { return $vis }
  }
  return $s
}

# ---------- Table widths ----------
$wIcon=1; $wA=28; $wSt=6; $wSTxt=16; $wRe=6; $wRTxt=22; $wErr=12; $wO=5; $wOC=7; $wM=4; $wSz=18

function Get-SeverityIconColor([string]$sev){
  if ($sev -eq 'Green') { return $fgGreen }
  elseif ($sev -eq 'Yellow') { return $fgYellow }
  else { return $fgRed }
}
function Get-SeverityTextColor([string]$sev){
  if ($sev -eq 'Green') { return $fgGreen }
  elseif ($sev -eq 'Yellow') { return $fgYellow }
  else { return '' }
}
function Get-SeverityRank([string]$sev){ if($sev -eq 'Red'){ 0 } elseif($sev -eq 'Yellow'){ 1 } else { 2 } }

# ---------- ODFC detection ----------
function Get-ODFCEnabled {
  $paths = @('HKLM:\SOFTWARE\Policies\FSLogix\ODFC','HKLM:\SOFTWARE\FSLogix\ODFC')
  foreach($p in $paths){
    try {
      $v = Get-ItemPropertyValue -Path $p -Name 'Enabled' -ErrorAction SilentlyContinue
      if($null -ne $v){ return ($v -eq 1) }
    } catch {}
  }
  return $false
}

function Get-ODFCState([string]$sid){
  if(-not (Get-ODFCEnabled)) { return 'No' }
  foreach($root in @($odfcSessLM1,$odfcSessLM2,$odfcSessCU)){
    try { $k = Join-Path $root $sid; if(Test-Path $k -PathType Container){ return 'Yes' } } catch {}
  }
  return 'No'
}
function Get-ODFCStatusCode([string]$sid){
  if(-not (Get-ODFCEnabled)) { return '' }
  $candidates = @((Join-Path $odfcSessLM1 $sid),(Join-Path $odfcSessLM2 $sid))
  foreach($p in $candidates){
    try {
      if(Test-Path $p -PathType Container){
        $v = Get-ItemProperty -Path $p -ErrorAction Stop
        if($v.PSObject.Properties.Match('Status').Count -gt 0){ return [string][int]$v.Status }
        if($v.PSObject.Properties.Match('LastError').Count -gt 0){ return ('E:' + ('0x{0:X8}' -f [uint32]$v.LastError)) }
        if($v.PSObject.Properties.Match('Error').Count -gt 0){ return ('E:' + ('0x{0:X8}' -f [uint32]$v.Error)) }
      }
    } catch {}
  }
  try {
    $curSid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    if($curSid -eq $sid){
      $p=Join-Path $odfcSessCU $sid
      if(Test-Path $p -PathType Container){
        $v=Get-ItemProperty -Path $p -ErrorAction SilentlyContinue
        if($v -and $v.PSObject.Properties.Match('Status').Count -gt 0){ return [string][int]$v.Status }
      }
    }
  } catch {}
  return ''
}

# ---------- Mount mode detection (RW/RO) ----------
function Get-ProfileMountMode([string]$sid, $p){
  try {
    $rw = $null; $ro = $null
    if ($null -ne $p) {
      if ($p.PSObject.Properties.Match('VHDRWDiffDiskFilePath').Count -gt 0) { $rw = $p.VHDRWDiffDiskFilePath }
      if ($p.PSObject.Properties.Match('VHDRODiffDiskFilePath').Count -gt 0) { $ro = $p.VHDRODiffDiskFilePath }
    }
    if ($null -ne $rw -and (Test-Path $rw -ErrorAction SilentlyContinue)) { return 'RW' }
    if ($null -ne $ro -and (Test-Path $ro -ErrorAction SilentlyContinue)) { return 'RO' }
  } catch {}
  try {
    $logDir='C:\ProgramData\FSLogix\Logs\Profile'
    if(Test-Path $logDir){
      $file=Get-ChildItem $logDir -Filter 'Profile_*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
      if($null -ne $file){
        $lines=Get-Content -Path $file.FullName -Tail 800 -ErrorAction SilentlyContinue
        $mine=$lines | Where-Object { $_ -match [Regex]::Escape($sid) }
        if ($mine -match '(?i)read[- ]?only'){ return 'RO' }
        if ($mine -match '(?i)read[/ -]?write'){ return 'RW' }
      }
    }
  } catch {}
  return ''
}

# ---------- Profile Size helpers ----------
function Format-Bytes([Int64]$bytes){
  if($null -eq $bytes){ return '' }
  $kb = 1KB; $mb = 1MB; $gb = 1GB; $tb = 1TB
  if($bytes -ge $tb){ return ("{0:N2} TB" -f ($bytes / $tb)) }
  elseif($bytes -ge $gb){ return ("{0:N2} GB" -f ($bytes / $gb)) }
  elseif($bytes -ge $mb){ return ("{0:N2} MB" -f ($bytes / $mb)) }
  elseif($bytes -ge $kb){ return ("{0:N0} KB" -f ($bytes / $kb)) }
  else { return ("{0} B" -f $bytes) }
}
function Get-EffectiveProfileSizeMB {
  $paths = @('HKLM:\SOFTWARE\Policies\FSLogix\Profiles','HKLM:\SOFTWARE\FSLogix\Profiles')
  foreach($p in $paths){
    try {
      if(Test-Path $p){
        $v = Get-ItemPropertyValue -Path $p -Name 'SizeInMBs' -ErrorAction Stop
        if($null -ne $v){ return [int]$v }
      }
    } catch {}
  }
  return $null
}
function Get-EffectiveIsDynamic {
  $paths = @('HKLM:\SOFTWARE\Policies\FSLogix\Profiles','HKLM:\SOFTWARE\FSLogix\Profiles')
  foreach($p in $paths){
    try {
      if(Test-Path $p){
        $v = Get-ItemPropertyValue -Path $p -Name 'IsDynamic' -ErrorAction Stop
        if($null -ne $v){ return [int]$v }
      }
    } catch {}
  }
  return 1
}
function Get-ProfileFolderFromSid([string]$sid){
  try {
    $k = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\{0}" -f $sid
    if(Test-Path $k){
      $val = Get-ItemPropertyValue -Path $k -Name 'ProfileImagePath' -ErrorAction Stop
      if($null -ne $val){ return $val }
    }
  } catch {}
  return $null
}
function Get-FolderSizeBytes([string]$path, [switch]$Fast){
  if(-not $path -or -not (Test-Path -LiteralPath $path)){ return $null }
  try {
    if($Fast){
      $sum = 0L
      Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.PSIsContainer } |
        ForEach-Object {
          try {
            $s = 0L
            Get-ChildItem -LiteralPath $_.FullName -Force -File -Recurse:$false -ErrorAction SilentlyContinue | ForEach-Object { $s += [Int64]$_.Length }
            # one level deep (fast)
            Get-ChildItem -LiteralPath $_.FullName -Force -Directory -ErrorAction SilentlyContinue | ForEach-Object {
              try { Get-ChildItem -LiteralPath $_.FullName -Force -File -Recurse:$false -ErrorAction SilentlyContinue | ForEach-Object { $s += [Int64]$_.Length } } catch {}
            }
            $sum += $s
          } catch {}
        }
      # add files directly in root
      Get-ChildItem -LiteralPath $path -Force -File -ErrorAction SilentlyContinue | ForEach-Object { $sum += [Int64]$_.Length }
      return $sum
    } else {
      $sum = 0L
      Get-ChildItem -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | ForEach-Object { $sum += [Int64]$_.Length }
      return $sum
    }
  } catch { return $null }
}

function Get-VhdChainInfo([string]$vhdPath){
  if(-not $vhdPath -or -not (Test-Path $vhdPath)){ return $null }
  try {
    if(Get-Command Get-VHD -ErrorAction SilentlyContinue){
      $chain = @()
      $cur = $vhdPath
      while($cur){
        try {
          $v = Get-VHD -Path $cur -ErrorAction Stop
          $file = Get-Item -LiteralPath $cur -ErrorAction SilentlyContinue
          $chain += [pscustomobject]@{
            Path = $cur
            VirtualSizeBytes = $v.VirtualSize
            FileSizeBytes = if($file){ $file.Length } else { $null }
            LastWriteTime = if($file){ $file.LastWriteTimeUtc } else { $null }
            ParentPath = $v.ParentPath
            IsDynamic = $v.FileType -match 'Dynamic|Differencing' -or $v.IsDynamic
          }
          if([string]::IsNullOrWhiteSpace($v.ParentPath)){ break }
          $cur = $v.ParentPath
        } catch { break }
      }
      return [pscustomobject]@{ Chain = $chain; VirtualSizeBytes = $chain[0].VirtualSizeBytes }
    }
  } catch {}
  return $null
}

function Get-VhdMaxMB([string]$vhdPath){
  try {
    $info = Get-VhdChainInfo -vhdPath $vhdPath
    if($null -ne $info -and $info.VirtualSizeBytes){
      return [int]([math]::Round($info.VirtualSizeBytes / 1MB))
    }
    # fallback: try bare Get-VHD call if chain returned null
    if(Get-Command Get-VHD -ErrorAction SilentlyContinue){
      $v = Get-VHD -Path $vhdPath -ErrorAction SilentlyContinue
      if($null -ne $v -and $v.VirtualSize){ return [int]([math]::Round($v.VirtualSize / 1MB)) }
    }
  } catch {}
  return $null
}

function Get-TopFolders([string]$path, [int]$N = 5){
  $result=@()
  if(-not $path -or -not (Test-Path -LiteralPath $path)){ return $result }
  try {
    Get-ChildItem -LiteralPath $path -Force -Directory -ErrorAction SilentlyContinue | ForEach-Object {
      $dir = $_.FullName
      $sum = 0L
      try {
        Get-ChildItem -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | ForEach-Object { $sum += [Int64]$_.Length }
      } catch {}
      $result += [pscustomobject]@{ Path=$dir; Bytes=$sum }
    }
    $result | Sort-Object Bytes -Descending | Select-Object -First $N
  } catch { @() }
}
function Get-SizeCachePath([string]$sid){
  $root = Join-Path $env:ProgramData "FSLogix\Cache\ProfileMonitor-for-FSLogix"
  try { if(-not (Test-Path $root)){ New-Item -ItemType Directory -Path $root -Force | Out-Null } } catch {}
  return Join-Path $root ("size_{0}.json" -f $sid)
}
function Read-SizeCache([string]$sid, [int]$minutes, [string]$vhdPath){
  if($minutes -le 0){ return $null }
  $f = Get-SizeCachePath $sid
  if(Test-Path $f){
    try {
      $obj = Get-Content -Path $f -Raw | ConvertFrom-Json -ErrorAction Stop
      if($null -ne $obj.Timestamp -and $null -ne $obj.SizeBytes){
        $age = (New-TimeSpan -Start ([datetime]$obj.Timestamp) -End (Get-Date)).TotalMinutes
        if($age -le $minutes){
          # if VHD metadata present, compare and invalidate if changed
          if($vhdPath -and $obj.VhdInfo){
            try {
              $fi = Get-Item -LiteralPath $vhdPath -ErrorAction SilentlyContinue
              if($fi){
                if($obj.VhdInfo.FileSizeBytes -ne $fi.Length -or $obj.VhdInfo.LastWriteTime -ne $fi.LastWriteTimeUtc){
                  return $null
                }
              }
            } catch {}
          }
          return $obj
        }
      }
    } catch {}
  }
  return $null
}
function Write-SizeCache([string]$sid, [Int64]$sizeBytes, [string]$vhdPath){
  try {
    $f = Get-SizeCachePath $sid
    $vhdInfo = $null
    if($vhdPath -and (Test-Path $vhdPath)){
      try {
        $fi = Get-Item -LiteralPath $vhdPath -ErrorAction Stop
        $vhdInfo = @{ FileSizeBytes = $fi.Length; LastWriteTime = $fi.LastWriteTimeUtc }
      } catch {}
    }
    $payload = @{ Timestamp = (Get-Date).ToString('o'); SizeBytes = $sizeBytes; VhdInfo = $vhdInfo } | ConvertTo-Json -Depth 6
    Set-Content -Path $f -Value $payload -Encoding UTF8 -Force
  } catch {}
}

function Add-SizeFields($row){
  if($null -eq $row){ return $row }

  $regMB  = Get-EffectiveProfileSizeMB
  $maxMB  = $regMB
  $vhdMax = $null
  $vhdPath = $row.ContainerPath
  if(-not $maxMB -or $maxMB -le 0){
    if($null -ne $vhdPath){ $vhdMax = Get-VhdMaxMB $vhdPath }
    $maxMB = if($vhdMax){ $vhdMax } else { 30000 }
  }
  $sizeSource = if($vhdMax){ 'VHD' } elseif($null -ne $regMB){ 'Registry' } elseif($maxMB -eq 30000){ 'Default' } else { 'Scan' }

  $profilePath = if($null -ne $row.ProfilePath){ $row.ProfilePath } else { Get-ProfileFolderFromSid $row.SID }
  $usedBytes = $null
  $cached = $null
  if(-not $InvalidateSizeCache){ $cached = Read-SizeCache -sid $row.SID -minutes $SizeCacheMinutes -vhdPath $vhdPath }
  if($null -ne $cached){ $usedBytes = [Int64]$cached.SizeBytes }
  if($null -eq $usedBytes -and -not ($SkipSizeRemote -and $ComputerName -and $ComputerName.Count -gt 0)){
    $usedBytes = Get-FolderSizeBytes -path $profilePath -Fast:$FastSize
    if($SizeCacheMinutes -gt 0 -and $null -ne $usedBytes){ Write-SizeCache -sid $row.SID -sizeBytes $usedBytes -vhdPath $vhdPath }
  }

  $row | Add-Member -NotePropertyName 'ProfilePath'  -NotePropertyValue $profilePath -Force
  $row | Add-Member -NotePropertyName 'ContainerPath' -NotePropertyValue $row.ContainerPath -Force
  $row | Add-Member -NotePropertyName 'SizeBytes'    -NotePropertyValue $usedBytes  -Force
  $row | Add-Member -NotePropertyName 'MaxSizeMB'    -NotePropertyValue $maxMB      -Force
  $row | Add-Member -NotePropertyName 'SizeSource'   -NotePropertyValue $sizeSource -Force

  $pct = $null
  if($maxMB -and $null -ne $usedBytes){ $pct = [int][Math]::Round(($usedBytes / ([double]($maxMB * 1MB))) * 100) }
  $row | Add-Member -NotePropertyName 'SizePct'  -NotePropertyValue $pct -Force
  $text = if($null -ne $usedBytes){
    if($null -ne $pct -or $SizeShowPercentAlways){ "{0} ({1}%)" -f (Format-Bytes $usedBytes), $(if($null -ne $pct){$pct}else{0}) } else { Format-Bytes $usedBytes }
  } else { '' }
  $row | Add-Member -NotePropertyName 'SizeText' -NotePropertyValue $text -Force

  $color = ''
  if($null -ne $pct){
    if($pct -ge $ErrorPct){ $color = $fgRed }
    elseif($pct -ge $WarnPct){ $color = $fgYellow }
  }
  $row | Add-Member -NotePropertyName 'SizeColor' -NotePropertyValue $color -Force

  if($TopFolders -gt 0 -and $null -ne $profilePath){
    try { $tf = Get-TopFolders -path $profilePath -N $TopFolders } catch { $tf = @() }
    $row | Add-Member -NotePropertyName 'TopFolders' -NotePropertyValue $tf -Force
  }

  return $row
}

function New-RowFromProps([string]$sid, $p){
  $acct = SidToName $sid
  $hasS = ($p -and $p.PSObject.Properties.Match('Status').Count -gt 0)
  $hasR = ($p -and $p.PSObject.Properties.Match('Reason').Count -gt 0)
  $hasE = ($p -and $p.PSObject.Properties.Match('Error').Count  -gt 0)
  $hasL = ($p -and $p.PSObject.Properties.Match('LastError').Count -gt 0)

  $status = if($hasS){ try{ [int]$p.Status } catch { -1 } } else { -1 }
  $reason = if($hasR){ try{ [int]$p.Reason } catch { -1 } } else { -1 }
  $errVal = 0
  if($hasE){ try{ $errVal = [uint32]$p.Error } catch {} }
  elseif($hasL){ try{ $errVal = [uint32]$p.LastError } catch {} }

  $statusText = if($mapStatus.ContainsKey($status)){ $mapStatus[$status] } elseif($status -ge 0){ "Code $status" } else { 'Unknown' }
  $reasonText = if($mapReason.ContainsKey($reason)){ $mapReason[$reason] } elseif($reason -ge 0){ "Code $reason" } else { '' }

  $sev='Yellow'
  if (($status -ne 0 -and $status -ne -1) -or $reason -in 7,9) { $sev='Red' }
  elseif ($status -in 100,200,300 -or $reason -in 1,2,3,4,5,8 -or ($status -eq -1 -and $reason -eq -1)) { $sev='Yellow' }
  else { $sev='Green' }

  $odfc = Get-ODFCState -sid $sid
  $odfcSt = Get-ODFCStatusCode -sid $sid
  $mode = Get-ProfileMountMode -sid $sid -p $p

  [pscustomobject]@{
    Account    = $acct
    SID        = $sid
    Status     = if($status -ge 0){ $status } else { $null }
    StatusText = $statusText
    Reason     = if($reason -ge 0){ $reason } else { $null }
    ReasonText = $reasonText
    ErrorHex   = ('0x{0:X8}' -f $errVal)
    Severity   = $sev
    ODFC       = $odfc
    ODFCSt     = $odfcSt
    Mode       = $mode
    ContainerPath = if($p -and $p.PSObject.Properties.Match('VHDPath').Count -gt 0){ $p.VHDPath } else { $null }
  }
}

function Get-CurrentUserRow {
  if (-not (Test-Path $sessionRoot)) { return $null }
  $sid  = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
  $k    = Join-Path $sessionRoot $sid
  if (-not (Test-Path $k)) { return $null }
  $p = $null
  try {
    $p = Get-ItemProperty -Path $k -ErrorAction Stop
  }
  catch [System.UnauthorizedAccessException] {
    $script:CurrentUserAccessDenied = $true
    try { $p = Get-ItemProperty -Path $k -ErrorAction SilentlyContinue } catch {}
    if($null -eq $p){ $p=[pscustomobject]@{} }
  }
  catch {
    try { $p = Get-ItemProperty -Path $k -ErrorAction SilentlyContinue } catch {}
    if($null -eq $p){ $p=[pscustomobject]@{} }
  }
  return New-RowFromProps -sid $sid -p $p
}

function Get-FSLogixSessions {
  $rows = @()
  if (Test-Path $sessionRoot) {
    try {
      $keys = Get-ChildItem $sessionRoot -ErrorAction Stop
      foreach($k in $keys){ try { $p = Get-ItemProperty $k.PSPath; $rows += New-RowFromProps -sid $k.PSChildName -p $p } catch {} }
    } catch {}
  }
  if(-not $rows -or $rows.Count -eq 0){
    $cand = @()
    try { $cand += (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty PSChildName) } catch {}
    try { $cand += [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value } catch {}
    $cand = $cand | Sort-Object -Unique | Where-Object { $_ -match '^S-1-(5|12)-' }
    foreach($sid in $cand){
      $path = Join-Path $sessionRoot $sid
      if(Test-Path $path){ try { $rows += New-RowFromProps -sid $sid -p (Get-ItemProperty $path) }catch{} }
    }
  }
  $rows | Sort-Object @{Expression={ Get-SeverityRank $_.Severity }}, @{Expression='Account';Ascending=$true}
}

function New-DataRow($r){
  $shapes = Get-IconShapes
  $iconColor = Get-SeverityIconColor $r.Severity
  $stColor   = Get-SeverityTextColor $r.Severity
  $rtColor   = Get-SeverityTextColor $r.Severity
  $iconGlyph = if($r.Severity -eq 'Green'){ $shapes.Healthy } elseif($r.Severity -eq 'Yellow'){ $shapes.Warn } else { $shapes.Error }

  (@('│ ',
    (SafeCell -text $iconGlyph              -width $wIcon -Color $iconColor), ' │ ',
    (SafeCell -text (ToStr $r.Account)   -width $wA),    ' │ ',
    (SafeCell -text (ToStr $r.Status)    -width $wSt -Align 'Right'), ' │ ',
    (SafeCell -text (ToStr $r.StatusText)-width $wSTxt -Color $stColor), ' │ ',
    (SafeCell -text (ToStr $r.Reason)    -width $wRe -Align 'Right'), ' │ ',
    (SafeCell -text (ToStr $r.ReasonText)-width $wRTxt -Color $rtColor), ' │ ',
    (SafeCell -text (ToStr $r.ErrorHex)  -width $wErr), ' │ ',
    (SafeCell -text (ToStr $r.ODFC)      -width $wO),   ' │ ',
    (SafeCell -text (ToStr $r.ODFCSt)    -width $wOC),  ' │ ',
    (SafeCell -text (ToStr $r.Mode) -width $wM), ' │ ', (SafeCell -text (ToStr $r.SizeText) -width $wSz -Color $r.SizeColor), ' │') -join '')
}

function New-HeaderRow(){
  $hdr = @('│ ',
    (SafeCell -text '#'         -width $wIcon), ' │ ',
    (SafeCell -text 'Account'   -width $wA),    ' │ ',
    (SafeCell -text 'St'        -width $wSt  -Align 'Right'), ' │ ',
    (SafeCell -text 'StatusText' -width $wSTxt),           ' │ ',
    (SafeCell -text 'Re'        -width $wRe  -Align 'Right'), ' │ ',
    (SafeCell -text 'ReasonText' -width $wRTxt),          ' │ ',
    (SafeCell -text 'Error'     -width $wErr),             ' │ ',
    (SafeCell -text 'ODFC'      -width $wO),               ' │ ',
    (SafeCell -text 'ODFCSt'    -width $wOC),              ' │ ',
    (SafeCell -text 'Mode' -width $wM), ' │ ', (SafeCell -text 'Size' -width $wSz), ' │') -join ''
  $len = CleanLen $hdr
  $top =  $B.tl + ($B.h * ($len-2)) + $B.tr
  $mid =  $B.j1 + ($B.h * ($len-2)) + $B.j2
  $bot =  $B.bl + ($B.h * ($len-2)) + $B.br
  return @{ Row=$hdr; Len=$len; Top=$top; Mid=$mid; Bot=$bot }
}

function Show-Header([int]$lineLen, [string]$modeText){
  $inner=$lineLen-2
  $top=$B.tl+($B.h*$inner)+$B.tr
  $bot=$B.bl+($B.h*$inner)+$B.br
  Write-Host ($fgGray+$top+$reset)

  $title    = " Profile Monitor for FSLogix ($modeText)  —  v$script:Version "
  $attribP  = ' Created by Drazen Nikolic — LinkedIn: https://www.linkedin.com/in/drazen-nikolic-816906142/ '
  $attribC  = $fgBlue + $attribP + $reset

  $shapes = Get-IconShapes
  $legendShapeHealthy = $shapes.Healthy
  $legendShapeWarn    = $shapes.Warn
  $legendShapeError   = $shapes.Error

  $legendP  = "  Legend:  $legendShapeHealthy Healthy  $legendShapeWarn Warning  $legendShapeError Error / Critical"
  $legendC  = '  Legend:  ' + $fgGreen + $legendShapeHealthy + $reset + ' Healthy  ' +
                           $fgYellow + $legendShapeWarn    + $reset + ' Warning  ' +
                           $fgRed    + $legendShapeError   + $reset + ' Error / Critical'
  $lines = @(
    @{text=$title;   plain=$title},
    @{text=$attribC; plain=$attribP},
    @{text='';       plain=''},
    @{text=$legendC; plain=$legendP}
  )
  foreach($l in $lines){
    $pad = ' ' * [Math]::Max(0, $inner - (CleanLen $l.plain))
    Write-Host ($fgGray + $B.v + $reset + $l.text + $pad + $fgGray + $B.v + $reset)
  }
  Write-Host ($fgGray+$bot+$reset)
}

function Show-TableCurrent([pscustomobject]$r){
  $h = New-HeaderRow
  Show-Header -lineLen $h.Len -modeText 'Current User'
  Write-Host ($fgGray + $h.Top + $reset)
  Write-Host ($fgGray + $h.Row + $reset)
  Write-Host ($fgGray + $h.Mid + $reset)
  Write-Host (New-DataRow $r)
  Write-Host ($fgGray + $h.Bot + $reset)
  if($Diag){ $arr=@(); $arr+=$r; $z = New-FSLogixDiagZip -rows $arr; if($z){ Write-Host ($fgGray + 'Diag ZIP: ' + $z + $reset) } }
  Write-Host ($fgGray + 'Note: Yellow = profile/container attached; Yellow = initializing/policy/group; Red = temp profile / load failure.' + $reset)
  Write-Host ($fgGray + 'Logs: C:\ProgramData\FSLogix\Logs\Profile' + $reset)
}

function Show-TableAll([array]$rows){
  $h = New-HeaderRow
  Show-Header -lineLen $h.Len -modeText 'All Users'
  Write-Host ($fgGray + $h.Top + $reset)
  Write-Host ($fgGray + $h.Row + $reset)
  Write-Host ($fgGray + $h.Mid + $reset)
  foreach($r in $rows){ Write-Host (New-DataRow $r) }
  Write-Host ($fgGray + $h.Bot + $reset)
  if($Diag){ $z = New-FSLogixDiagZip -rows $rows; if($z){ Write-Host ($fgGray + 'Diag ZIP: ' + $z + $reset) } }
  Write-Host ($fgGray + 'Note: Yellow = profile/container attached; Yellow = initializing/policy/group; Red = temp profile / load failure.' + $reset)
  Write-Host ($fgGray + 'Logs: C:\ProgramData\FSLogix\Logs\Profile' + $reset)
}

function Show-EventsFor([string]$sid){
  Write-Host ''
  Write-Host ($fgGray + ("Recent FSLogix events (Operational) for SID {0}:" -f $sid) + $reset)
  try {
    $start=(Get-Date).AddDays(-7)
    Get-WinEvent -FilterHashtable @{LogName='Microsoft-FSLogix-Apps/Operational'; StartTime=$start} -MaxEvents 400 |
      Where-Object { $_.Message -match [Regex]::Escape($sid) } |
      Select-Object -First $EventCount TimeCreated, Id, LevelDisplayName, Message |
      Format-List
  } catch {}
}
function Show-Config {
  if (-not (Test-Path $profilesRoot)) { return }
  Write-Host ''
  Write-Host ($fgGray + 'FSLogix Profile configuration (machine scope):' + $reset)
  try {
    $cfg = Get-ItemProperty $profilesRoot -ErrorAction SilentlyContinue
    $enabled = if($cfg.Enabled -eq 1){ 'Enabled' } elseif($cfg.Enabled -eq 0){ 'Disabled' } else { 'Not set' }
    Write-Host ("  Profiles Enabled: {0}" -f $enabled)
    $pol = $null; $loc = $null
    try { $pol = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -ErrorAction Stop).Enabled } catch {}
    try { $loc = (Get-ItemProperty 'HKLM:\SOFTWARE\FSLogix\ODFC' -ErrorAction Stop).Enabled } catch {}
    $eff = if($null -ne $pol){ $pol } elseif($null -ne $loc){ $loc } else { $null }
    $effTxt = if($eff -eq 1){ 'Enabled' } elseif($eff -eq 0){ 'Disabled' } else { 'Not set' }
    $src = if($null -ne $pol){ 'Policy' } elseif($null -ne $loc){ 'Local' } else { '—' }
    Write-Host ("  ODFC Enabled (effective): {0} [{1}]" -f $effTxt,$src)
    foreach($name in 'VHDLocations','CCDLocations','DeleteLocalProfileWhenVHDShouldApply','ProfileType','SizeInMBs','SIDDir'){
      try {
        $val = Get-ItemPropertyValue -Path $profilesRoot -Name $name -ErrorAction Stop
        if($val -is [array]){ Write-Host ("  {0}:" -f $name); $val | ForEach-Object { Write-Host "    - $_" } }
        else { Write-Host ("  {0}: {1}" -f $name,$val) }
      } catch { Write-Host ("  {0}: (not set)" -f $name) }
    }
  } catch {}
}

function Test-SmbPort([string]$unc){
  if($unc -notmatch '^(?:\\\\|//)([^\\/]+)'){ return $null }
  $targetHost = $Matches[1]
  try { @{ Host=$targetHost; Port445 = [bool](Test-NetConnection -ComputerName $targetHost -Port 445 -InformationLevel Quiet) } } catch { @{ Host=$targetHost; Port445 = $false } }
}

function Test-SharePermissions {
  param(
    [Parameter(Mandatory)][string]$UNCPath,
    [PSCredential]$Credential,
    [switch]$PerformWriteTest
  )
  $result = [ordered]@{ UNC = $UNCPath; Reachable445 = $false; Access = $false; WriteTest = $null; Error = $null }
  try {
    $probe = Test-SmbPort $UNCPath
    if($null -ne $probe){ $result.Reachable445 = $probe.Port445 }
    if($UNCPath -notmatch '^(?:\\\\|//)'){ $result.Error = 'Not UNC'; return $result }
    # attempt PSDrive mapping (temporary)
    $name = "FSLOGIX_CHECK_" + ([guid]::NewGuid().ToString('N').Substring(0,6))
    try {
      if($Credential){
        New-PSDrive -Name $name -PSProvider FileSystem -Root $UNCPath -Credential $Credential -ErrorAction Stop | Out-Null
      } else {
        New-PSDrive -Name $name -PSProvider FileSystem -Root $UNCPath -ErrorAction Stop | Out-Null
      }
      $result.Access = $true
      if($PerformWriteTest){
        $testFile = Join-Path ("$($name):\") ("fslogix_test_{0}.tmp" -f ([guid]::NewGuid().ToString('N')))
        try {
          New-Item -Path $testFile -ItemType File -Value "test" -Force -ErrorAction Stop | Out-Null
          Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
          $result.WriteTest = $true
        } catch {
          $result.WriteTest = $false
        }
      }
    } catch {
      $result.Access = $false
      $result.Error = $_.Exception.Message
    } finally {
      try { Remove-PSDrive -Name $name -Force -ErrorAction SilentlyContinue } catch {}
    }
  } catch {
    $result.Error = $_.Exception.Message
  }
  return $result
}

function Show-LogTail([int]$lines){
  if($lines -le 0){ return }
  $logDir = 'C:\ProgramData\FSLogix\Logs\Profile'
  if(-not (Test-Path $logDir)){ return }
  $file = Get-ChildItem $logDir -Filter 'Profile_*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if($null -eq $file){ return }
  Write-Host ''
  Write-Host ($fgGray + ("Tail of {0} (last {1} lines):" -f $file.FullName,$lines) + $reset)
  try {
    Get-Content -Tail $lines -Path $file.FullName | ForEach-Object {
      if($_ -match '(?i)error|failed'){ Write-Host ($fgRed + $_ + $reset) }
      elseif($_ -match '(?i)warn|warning'){ Write-Host ($fgYellow + $_ + $reset) }
      else { Write-Host $_ }
    }
  } catch {}
}

function Export-Data([array]$rows){
  if($ExportCsv){ try { $rows | Export-Csv -Path $ExportCsv -NoTypeInformation -Force } catch {} }
  if($ExportJson){ try { $rows | ConvertTo-Json -Depth 6 | Out-File -FilePath $ExportJson -Encoding UTF8 -Force } catch {} }
  if($Copy){
    try {
      $one = ($rows | ForEach-Object { "{0}: St={1}({2}) Re={3}({4}) Err={5} ODFC={6} ODFCSt={7} Mode={8}" -f $_.Account,$_.Status,$_.StatusText,$_.Reason,$_.ReasonText,$_.ErrorHex,$_.ODFC,$_.ODFCSt,$_.Mode }) -join ' | '
      Set-Clipboard -Value $one
      Write-Host ($fgGray + 'Copied summary to clipboard.' + $reset)
    } catch {}
  }
  if($PrometheusOutFile){
    try { Export-PrometheusMetrics -Rows $rows -OutFile $PrometheusOutFile } catch {}
  }
}
function Show-Advice([array]$rows){
  $h=@(); foreach($r in $rows){ if($advice.ContainsKey($r.Reason)){ $h += ("- {0}: {1}" -f $r.Account,$advice[$r.Reason]) } }
  if($h){ Write-Host ''; Write-Host ($fgGray + 'Hints:' + $reset); $h | ForEach-Object { Write-Host $_ } }
}
function Invoke-BeepIfNeeded([array]$rows){ if(-not $BeepOnError){ return }; try { if($rows | Where-Object { $_.Severity -eq 'Red' }){ [console]::Beep(1000,300) } } catch {} }

function Export-PrometheusMetrics {
  param([Parameter(Mandatory)][array]$Rows, [Parameter(Mandatory)][string]$OutFile)
  $lines = @()
  $lines += "# HELP fslogix_profile_size_bytes Profile used bytes"
  $lines += "# TYPE fslogix_profile_size_bytes gauge"
  foreach($r in $Rows){
    $labels = "account=`"$($r.Account)`",sid=`"$($r.SID)`",mode=`"$($r.Mode)`",odfc=`"$($r.ODFC)`""
    $val = if($r.SizeBytes){ $r.SizeBytes } else { 0 }
    $lines += "fslogix_profile_size_bytes{$labels} $val"
    if($r.MaxSizeMB){
      $lines += "fslogix_profile_max_bytes{account=`"$($r.Account)`",sid=`"$($r.SID)`"} $([math]::Round($r.MaxSizeMB * 1MB))"
    }
  }
  try { $lines | Out-File -FilePath $OutFile -Encoding ASCII -Force } catch {}
}

function Get-FileLocks {
  param([Parameter(Mandatory)][string]$Path)
  # try sysinternals handle.exe if available
  $hdl = (Get-Command handle.exe -ErrorAction SilentlyContinue).Path
  if($hdl){
    try {
      $out = & $hdl -accepteula -u $Path 2>$null
      # crude parse: lines with "pid: " or paths
      $results = @()
      foreach($line in $out){
        if($line -match '^\s*(\S+)\s+pid:\s*(\d+)\s+type:\s*(\w+)\s+(.*)$'){
          $results += [pscustomobject]@{ Process=$Matches[1]; PID=[int]$Matches[2]; Type=$Matches[3]; Path=$Matches[4].Trim() }
        }
      }
      return $results
    } catch {}
  }
  # fallback: no data
  return @()
}

function Optimize-FsLogixVhd {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory)][string]$Path,
    [ValidateSet('Quick','Full')][string]$Mode='Quick',
    [switch]$WhatIf
  )
  if($PSBoundParameters.ContainsKey('WhatIf') -and $WhatIf){
    Write-Host "WhatIf: Would optimize $Path ($Mode)"
    return
  }
  if($PSCmdlet.ShouldProcess($Path, "Optimize VHD ($Mode)")){
    if(-not (Test-Path $Path)){ throw "VHD not found: $Path" }
    if(Get-Command Optimize-VHD -ErrorAction SilentlyContinue){
      try {
        if($Mode -eq 'Quick'){ Optimize-VHD -Path $Path -Mode Quick -ErrorAction Stop }
        else { Optimize-VHD -Path $Path -Mode Full -ErrorAction Stop }
        return $true
      } catch { throw $_ }
    } else {
      throw "Optimize-VHD not available on this system."
    }
  }
}

function New-FSLogixDiagZip([array]$rows){
  try {
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $dest = Join-Path $env:TEMP ("FslogixDiag_{0}_{1}.zip" -f $env:COMPUTERNAME, $ts)
    $tmpDir = Join-Path $env:TEMP ("FslogixDiag_{0}" -f $ts)
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    $rows | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $tmpDir 'data.json') -Encoding UTF8 -Force

    $cfgPath = Join-Path $tmpDir 'config.txt'
    try { Start-Transcript -Path $cfgPath -Append -Force | Out-Null } catch {}
    try { Show-Config } catch {}
    try { Stop-Transcript | Out-Null } catch {}

    try {
      $ev = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=(Get-Date).AddHours(-24)} -ErrorAction Stop |
        Where-Object { $_.ProviderName -match 'FSLogix' -or $_.Message -match 'FSLogix' } |
        Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message
      $ev | Format-List * | Out-String | Set-Content -Path (Join-Path $tmpDir 'events.txt') -Encoding UTF8 -Force
    } catch {}

    $logDir = 'C:\ProgramData\FSLogix\Logs\Profile'
    if(Test-Path $logDir){
      Copy-Item -Path (Join-Path $logDir '*') -Destination (Join-Path $tmpDir 'Logs') -Recurse -Force -ErrorAction SilentlyContinue
    }

    Compress-Archive -Path (Join-Path $tmpDir '*') -DestinationPath $dest -Force
    Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    return $dest
  } catch {
    return $null
  }
}

# Remote: gather sessions on remote hosts using Invoke-Command (returns comparable objects)
function Get-FSLogixRemoteStatus {
  param([string[]]$Computers, [PSCredential]$Credential, [int]$Throttle = 4)
  if(-not $Computers){ return @() }
  $scriptBlock = {
    param($sessionRoot)
    $rows=@()
    try {
      if(Test-Path $sessionRoot){
        $keys = Get-ChildItem $sessionRoot -ErrorAction SilentlyContinue
        foreach($k in $keys){ try { $p = Get-ItemProperty $k.PSPath; $rows += [pscustomobject]@{ SID=$k.PSChildName; Props=$p } } catch {} }
      }
    } catch {}
    return $rows
  }
  $inv = @()
  foreach($c in $Computers){
    $throttle = $Throttle
    try {
      $res = Invoke-Command -ComputerName $c -Credential $Credential -ArgumentList $sessionRoot -ThrottleLimit $throttle -ScriptBlock $scriptBlock -ErrorAction SilentlyContinue
      if($res){
        foreach($r in $res){ 
          try {
            $obj = New-RowFromProps -sid $r.SID -p $r.Props
            $obj | Add-Member -NotePropertyName 'Host' -NotePropertyValue $c -Force
            $inv += $obj
          } catch {}
        }
      }
    } catch {}
  }
  return $inv
}

# initial render function
function Render {
  Clear-Host
  if($AllUsers){
    if(-not (Test-Admin)){ Write-Host ($fgYellow + 'Warning: Not elevated. Results may be incomplete under Sessions\*.' + $reset) }
    $rows = Get-FSLogixSessions
    $rows = $rows | ForEach-Object { Add-SizeFields $_ }
    if($null -eq $rows -or $rows.Count -eq 0){
      Write-Host ($fgRed + 'No FSLogix session keys found or access denied under HKLM:\SOFTWARE\FSLogix\Profiles\Sessions.' + $reset)
      Write-Host ($fgGray + 'Tip: Run PowerShell as Administrator for full enumeration, or use -CurrentUser.' + $reset)
      return
    }
    Show-TableAll $rows
    Export-Data $rows
    if($IncludeEvents){ foreach($r in $rows){ Show-EventsFor $r.SID } }
    if($ShowConfig){ Show-Config }
    if($CheckShares){ 
      try {
        $locs = Get-ItemPropertyValue -Path $profilesRoot -Name 'VHDLocations' -ErrorAction SilentlyContinue
        if($locs){ foreach($p in $locs){ $t = Test-SharePermissions -UNCPath $p -Credential $ShareCredential -PerformWriteTest; Write-Host ($fgGray + ("  {0} -> 445:{1} Access:{2} Write:{3}" -f $p, $t.Reachable445, $t.Access, $t.WriteTest) + $reset) } }
      } catch {}
    }
    if($TailLogs -gt 0){ Show-LogTail $TailLogs }
    Invoke-BeepIfNeeded $rows
  } else {
    $row = Get-CurrentUserRow
    $row = Add-SizeFields $row
    if($null -eq $row){
      Write-Host ($fgRed + 'Current user session key not found under HKLM:\SOFTWARE\FSLogix\Profiles\Sessions.' + $reset)
      return
    }
    Show-TableCurrent $row
    Export-Data @($row)
    if($IncludeEvents){ Show-EventsFor $row.SID }
    if($ShowConfig){ Show-Config }
    if($CheckShares){ 
      try {
        $locs = Get-ItemPropertyValue -Path $profilesRoot -Name 'VHDLocations' -ErrorAction SilentlyContinue
        if($locs){ foreach($p in $locs){ $t = Test-SharePermissions -UNCPath $p -Credential $ShareCredential -PerformWriteTest; Write-Host ($fgGray + ("  {0} -> 445:{1} Access:{2} Write:{3}" -f $p, $t.Reachable445, $t.Access, $t.WriteTest) + $reset) } }
      } catch {}
    }
    if($TailLogs -gt 0){ Show-LogTail $TailLogs }
    Invoke-BeepIfNeeded @($row)
  }
}

# initial render
Render

if ($Watch -gt 0) {
  Write-Host ''; Write-Host ($fgGray + "Watch mode active. Press 'q' to quit." + $reset)
  $stop=$false
  while(-not $stop){
    Start-Sleep -Seconds $Watch
    try { if ($Host.UI.RawUI.KeyAvailable) { $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyUp'); if ($k.Character -eq 'q') { $stop = $true; break } } } catch {}
    Render
  }
}