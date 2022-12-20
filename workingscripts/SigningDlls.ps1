## Signing Each Individual Assembly of Type DLL ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$Repopath,
    [Parameter(Mandatory=$True)][string]$SigningCert
   
)
## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'Continue'
$ErrorActionPreference = 'Continue'
$VerbosePreference = 'Continue'
#$Repopath = "C:\Telemetry\opentelemetry-dotnet-contrib\"
#$SigningCert = "C:\Telemetry\mainpublicprivate.pfx"

Set-Location -Path $Repopath
$files = @('OpenTelemetry.dll', 'OpenTelemetry.exporter.opentelemetryprotocol.dll', 'OpenTelemetry.api.dll', 'OpenTelemetry.contrib.instrumentation.wcf.dll', 'OpenTelemetry.instrumentation.sqlclient.dll', 'OpenTelemetry.exporter.inmemory.dll', 'OpenTelemetry.exporter.console.dll')

$Sourcefiles = @(Get-ChildItem -Path $Repopath -Recurse | Where-Object {$_.Name -in @($files | ForEach-Object {$_}) } | Select Fullname)

#$Assemblies = @(Get-ChildItem -Path $Repopath -Recurse | Where {$_.Name -contains "OpenTelemetry.dll" -and "OpenTelemetry.api.dll" -and "OpenTelemetry.exporter.opentelemetryprotocol.dll" -and "OpenTelemetry.contrib.instrumentation.wcf.dll" -and "OpenTelemetry.instrumentation.sqlclient.dll" -and "OpenTelemetry.exporter.inmemory.dll" -and "OpenTelemetry.exporter.console.dll" } | Select Fullname)
$pattern1 = '@{FullName='
$pattern2 = '}'
$Replace = $Sourcefiles -replace $pattern1, $newvalue
$Assemblies = $Replace -replace $pattern2, $newvalue2


if ($Repopath -ccontains $Repopath) {
 
ForEach ( $Assembly in $Assemblies)
{
  Write-Host "Signing the Dotnet Assembly of Type DLL"
  signtool.exe sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /f $SigningCert /p apple@123 $Assembly
  Write-Host "$Assembly Signing Completed"
  
  #signtool.exe sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /f .\mainpublicprivate.pfx /p apple@123 $Assembly
}
Write-Host -ForegroundColor Yellow "[Time consumed to Digitally Sign these Assemblies is "$stopwatch.Elapsed.TotalSeconds" seconds]"
}