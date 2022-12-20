## Parameters for File Replacement on Local Machine ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)][string]$Sourcefile,
    [Parameter(Mandatory=$false)][string]$Destinationfolder
)
## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

$Sourcefile="./config.yaml"
$Destinationfolder="C:\Program Files\OpenTelemetry Collector Contrib"

## Cmdlets to replace file in destination folder ##
Get-Service | Where-Object name -eq otelcontribcol | Stop-Service
Copy-Item -Path $Sourcefile -Destination $Destinationfolder -Recurse -Force
Write-Host -ForegroundColor Yellow "[Time consumed to replace config file in "$stopwatch.Elapsed.TotalSeconds" seconds]"
Get-Service | Where-Object name -eq otelcontribcol | Start-Service
$stopwatch