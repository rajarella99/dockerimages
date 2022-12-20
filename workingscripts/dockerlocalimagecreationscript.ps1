## Provision Docker Images and Send to ACR using Powershell Script ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$FolderName,
    [Parameter()][string]$WindowsImagetag,
    [Parameter()][string]$LinuxImagetag   
)
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
Set-Location  -Path $FolderName -PassThru
$random = Get-Random -Maximum 10000
$WindowsImagetag = 'windows'
$LinuxImagetag = 'linux'
$dockerwindowsimage = $WindowsImagetag + "$random"
$dockerlinuximage = $LinuxImagetag + "$random"
$azurecontainerregistrywindows = "wkmarcosyard.azurecr.io/windows/images" + "$random"
$azurecontainerregistrylinux = "wkmarcosyard.azurecr.io/linux/images" + "$random"
$acrpassword = "7=HsIghiXgZDuRSYiH4fRPIdxyLENQYF"
$acrusername = "wkmarcosyard"
$registryname = "wkmarcosyard"
Connect-AzContainerRegistry  -Name  $registryname  -UserName $acrusername -Password $acrpassword 
$dv = docker version --format "{{json . }}"
$engineversion = $dv | ConvertFrom-Json
$engineversion.Server | Format-List



## Set Subscription for current working Tenant ##
$SubscriptionId = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext 
Write-Host "Getting AzContext for specific subscription"
Get-AzContext

## Main Script ##

Get-Service  |  Where  {$_.Name -eq "com.docker.service"}  ## Docker Desktop Service ##
Get-Service | Where {$_.Name -eq "docker"}  ## Docker Engine Service ##

$DesktopService =  Get-Service  |  Where  {$_.Name -eq "com.docker.service"} 
$EngineService = Get-Service | Where {$_.Name -eq "docker"}

### This Section Creates Windows Images ##
if ($engineversion.Server.Os -eq  "windows") {
if ( $DesktopService.Status -eq "Running" -and  $EngineService.Status -eq "Running") { 
Write-Host "Creating Docker Image with Image Name as  $dockerwindowsimage" -ForegroundColor Red
$dockerargs = @(
    "build"
    "-t"
    "$dockerwindowsimage"
    "."
)

Start-Process docker -Wait -ArgumentList $dockerargs 
Write-Host -ForegroundColor Yellow "[Time consumed to create this docker image is "$stopwatch.Elapsed.TotalSeconds" seconds]" 
Write-Host -ForegroundColor Magenta "Docker Image for Windows Containers Created for $dockerwindowsimage"

try {
$imageargs = @(
    "tag"
    "$dockerwindowsimage"
    "$azurecontainerregistrywindows"
)

$imagesend = @(
    "push"
    "$azurecontainerregistrywindows"
)

Start-Process docker -Wait -ArgumentList $imageargs
Start-Sleep -Seconds 5
Start-Process docker -Wait -ArgumentList $imagesend
}
catch {
Write-Host "Error sending image to azure container registry" $_.Exception.Message
throw $_
}
finally {
Write-Host -ForegroundColor Yellow "[Time consumed to create tag and push docker image is "$stopwatch.Elapsed.TotalSeconds" seconds]" 
}
} }





### This Section Creates Linux Images ##
if ($engineversion.Server.Os -eq  "linux") {
if ( $DesktopService.Status -eq "Running" -and  $EngineService.Status -eq "Running") { 
Write-Host "Creating Docker Image with Image Name as  $dockerlinuximage" -ForegroundColor Red
$dockerargs = @(
    "build"
    "-t"
    "$dockerlinuximage"
    "."
)

Start-Process docker -Wait -ArgumentList $dockerargs 
Write-Host -ForegroundColor Yellow "[Time consumed to create this docker image is "$stopwatch.Elapsed.TotalSeconds" seconds]" 
Write-Host -ForegroundColor Magenta "Docker Image for Linux Containers Created for $dockerlinuximage"

try {
$imageargs = @(
    "tag"
    "$dockerlinuximage"
    "$azurecontainerregistrylinux"
)

$imagesend = @(
    "push"
    "$azurecontainerregistrylinux"
)

Start-Process docker -Wait -ArgumentList $imageargs
Start-Sleep -Seconds 5
Start-Process docker -Wait -ArgumentList $imagesend
}
catch {
Write-Host "Error sending image to azure container registry" $_.Exception.Message
throw $_
}
finally {
Write-Host -ForegroundColor Yellow "[Time consumed to create tag and push docker image is "$stopwatch.Elapsed.TotalSeconds" seconds]" 
}
} }







