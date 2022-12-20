## Provision Azure Service Plan & Azure App Services ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$location,
    [Parameter(Mandatory=$True)][string]$RGName,
    [Parameter(Mandatory=$True)][string]$Kind,
    [Parameter(Mandatory=$True)][string]$acrloginserver,
    [Parameter(Mandatory=$True)][string]$serviceplanname,
    [Parameter(Mandatory=$True)][string]$webappname    
)
## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

#WEBAPP VARIABLES#
$acrstring = "7=HsIghiXgZDuRSYiH4fRPIdxyLENQYF"
$acrpassword =  $acrstring | ConvertTo-SecureString -AsPlainText -Force
$acrusername = $acrloginserver
$acrregistryname = "https://$acrloginserver.azurecr.io"
$acrimagename = "$acrloginserver.azurecr.io/$Kind/windowsotelimage:latest"
$acrwindowsimagename = "$acrloginserver.azurecr.io/$Kind/windowsotelimage:latest"
$acrlinuximagename = "$acrloginserver.azurecr.io/$Kind/telemetry2:0.34.0"	
$acrregistryurl = Get-AzContainerRegistry -ResourceGroupName Marcos -Name $acrloginserver

## Set Subscription for current working Tenant ##
$SubscriptionId = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
az account list -o table
az account set --subscription $SubscriptionId
Write-Host "Setting the Current Subscription to "TAA-CSO-Axcess_Always-On-Z-NONPRD-Labs" using azcli"
Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext
$currentsubscription = Get-AzContext 
Write-Host "The current Subscription is "$currentsubscription.Subscription.Name" " -ForegroundColor Magenta

##################################################################################################################################

# Create an App Service plan for Windows Platform Tier.

$planstatus = Get-AzAppServicePlan -ResourceGroupName $RGName -Name $serviceplanname 
if ($Kind -eq "windows") {
if ( $planstatus.ProvisioningState -ne "Succeeded") {
try {
Write-Host -ForegroundColor Magenta "The Windows App SERVICEPLAN creation in progress"
	$arguments = @{
		ResourceGroupName  =		$RGName
		Location  =				$location
		Name  = 					$serviceplanname
		Tier  =				"PremiumV3"
		NumberofWorkers  =   1	
		WorkerSize  =  "Medium"
		HyperV =		$True
        ErrorAction = 'Stop'
	}
$appstatus =  New-AzAppServicePlan @arguments
Write-Host -ForegroundColor Green "The Windows App SERVICEPLAN status is "$appstatus.ProvisioningState" and it has been created successfully"
Write-Host -ForegroundColor Yellow "[Time consumed to create this Azure Windows App SERVICEPLAN is "$stopwatch.Elapsed.TotalSeconds" seconds]"
} catch {
Write-Host -ForegroundColor Red "Error in Creating App SERVICEPLAN for $serviceplanname" 
throw $_
}
}
else { 
Write-Host  -ForegroundColor Red  "The AppService plan with $serviceplanname is already existing"
} 
} else {
Write-Host -ForegroundColor Red "The Parameter is not set to create Windows App SERVICEPLAN"
}


# Create an App Service plan for Linux Platform Tier.

$planstatus = Get-AzAppServicePlan -ResourceGroupName $RGName -Name $serviceplanname 
if ($Kind -eq "linux") {
if ( $planstatus.ProvisioningState -ne "Succeeded") {
try {
Write-Host -ForegroundColor Magenta "The Linux App SERVICEPLAN creation in progress"
	$arguments = @{
		ResourceGroupName  =		$RGName
		Location  =				$location
		Name  = 					$serviceplanname
		Tier  =				"PremiumV3"
		NumberofWorkers  =   1	
		WorkerSize  =  "Medium"
		Linux =		$True
        ErrorAction = 'Stop'
	}
$appstatus =  New-AzAppServicePlan @arguments
Write-Host -ForegroundColor Green "The Linux App SERVICEPLAN status is "$appstatus.ProvisioningState" and it has been created successfully"
Write-Host -ForegroundColor Yellow "[Time consumed to create this Azure Linux App SERVICEPLAN is "$stopwatch.Elapsed.TotalSeconds" seconds]"
} catch {
Write-Host -ForegroundColor Red "Error in Creating Linux App SERVICEPLAN for $serviceplanname" 
throw $_
}
}
else { 
Write-Host  -ForegroundColor Yellow  "The Linux App SERVICEPLAN with $serviceplanname is already existing"
}
} else {
Write-Host -ForegroundColor Red "The Parameter is not set to create Linux App SERVICEPLAN"
}

##########################################################################################################################################

# Create a WINDOWS WEB APP on AZURE APP SERVICE.
try {
$planstatus = Get-AzAppServicePlan -ResourceGroupName $RGName -Name $serviceplanname 
if ($Kind -eq "windows") {
$websitename = Get-AzWebApp 
if ( $planstatus.ProvisioningState -eq "Succeeded") {
Write-Host -ForegroundColor Green "The "$Kind" Web AppService creating "
#hashtable#
	$arguments = @{
		ResourceGroupName  =		$RGName
		Location  =				$location
		Name  = 					$webappname
		AppServicePlan =				$serviceplanname
		ContainerImageName  =   $acrwindowsimagename
		ContainerRegistryUrl   =    $acrregistryname
		ContainerRegistryUser =  $acrusername
        ContainerRegistryPassword = $acrpassword
        ErrorAction = 'Stop'
        Verbose = $true
	}
New-AzWebApp @arguments
Write-Host -ForegroundColor Yellow "The "$Kind" Web AppService created successfully "
#hashtable#
	$sitesettings = @{
		ResourceGroupName  =		$RGName		
		Name  = 					$webappname
		AppServicePlan =				$serviceplanname
        AppSettings =	@{	
		DOCKER_REGISTRY_SERVER_URL   =    "https://$acrloginserver.azurecr.io"
		DOCKER_REGISTRY_SERVER_USERNAME =  $acrusername
        DOCKER_REGISTRY_SERVER_PASSWORD = $acrstring
        WEBSITES_PORT = '4318'
        }
        AlwaysOn = $true
        ErrorAction = 'Continue'
        Verbose = $true
	}
Write-Host -ForegroundColor Green "The "$Kind" Web AppService is getting updated "
Set-AzWebApp @sitesettings
Write-Host -ForegroundColor Yellow "[Time consumed to create this Azure Windows Web App Service is "$stopwatch.Elapsed.TotalSeconds" seconds]"
}
} else {
Write-Host -ForegroundColor Red "The Parameter is not set to create Windows App Service"
}
} 
catch {
Write-Host -ForegroundColor Yellow "The Windows WEB APP Service creation failed catching error"
throw $_
}


# Create a Linux WEB APP on AZURE APP SERVICE.
try {
if ($Kind -ne "windows") {
Write-Host -ForegroundColor Green "Checking if "$Kind" web app can be created"
}
if ($Kind -eq "linux") {
Write-Host -ForegroundColor Yellow "The kind linux is existing hence script will try create linux web app"
Start-Sleep -s 10 -Verbose
$planstatus = Get-AzAppServicePlan -ResourceGroupName $RGName -Name $serviceplanname 
if ( $planstatus.Kind -eq "linux") {
Write-Host -ForegroundColor Green "The "$Kind" Web AppService creating "
#hashtable#
	$arguments = @{
		ResourceGroupName  =		$RGName
		Location  =				$location
		Name  = 					$webappname
		AppServicePlan =				$serviceplanname
		ContainerImageName  =   $acrlinuximagename
		ContainerRegistryUrl   =    $acrregistryname
		ContainerRegistryUser =  $acrusername
        ContainerRegistryPassword = $acrpassword
        #linuxFxVersion = "DOCKER|wkmarcosyard.azurecr.io/linux/telemetry2:0.34.0"
        ErrorAction = 'Stop'
        Verbose = $true
	}
New-AzWebApp @arguments
Write-Host -ForegroundColor Yellow "The "$Kind" Web AppService created successfully "
Start-Sleep -Seconds 18 -Verbose
#hashtable#
$sitesettings = @{
		ResourceGroupName  =		$RGName		
		Name  = 					$webappname
		AppServicePlan =				$serviceplanname
        AppSettings =	@{	
		DOCKER_REGISTRY_SERVER_URL   =    "https://$acrloginserver.azurecr.io"
		DOCKER_REGISTRY_SERVER_USERNAME =  $acrusername
        DOCKER_REGISTRY_SERVER_PASSWORD = $acrstring
        WEBSITES_ENABLE_APP_SERVICE_STORAGE = 'False'        
        WEBSITES_PORT = '4318'
        }        
        AlwaysOn = $true
        ErrorAction = 'Continue'
        Verbose = $true
	}
Write-Host -ForegroundColor Green "The "$Kind"  Web AppService is getting updated "
az webapp config container set --name $webappname  --resource-group $RGName --docker-custom-image-name $acrlinuximagename --docker-registry-server-url $acrregistryname --docker-registry-server-user $acrloginname --docker-registry-server-password $acrstring --verbose
Set-AzWebApp @sitesettings
Write-Host -ForegroundColor Yellow "[Time consumed to create this Azure Linux Web App Service is "$stopwatch.Elapsed.TotalSeconds" seconds]"
}
}
else {
Write-Host -ForegroundColor Red "The Parameter is not set to create Linux App Service"
}
} 
catch {
Write-Host -ForegroundColor Yellow "The Linux WEB APP Service creation failed catching error"
throw $_
}


