## Provision Azure Container Registry Script ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$ContainerName,
    [Parameter(Mandatory=$True)][string]$RGName,
    [Parameter(Mandatory=$True)][string]$SkuVersion
   # [Parameter()][switch]$updatecontainerregistry
    
)
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
$start = Get-Date
$latestSkuVersion = "Basic"
$defaultRGName = "Marcos"
#$username = "spaceshuttle\dcadmin"
#$secpasswd = 'abcd@!2'
#$log = "$env:TEMP\remote-otel-app.txt"
#$cred = New-Object System.Management.Automation.PScredential -ArgumentList @($username,(ConvertTo-SecureString -String $secpasswd -AsPlainText -Force))
#$LocationName = "centralus"
#$diagSa = 'phoenixwkstorage'
#$saRg = 'Dev-Rg'

$SubscriptionId = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext 
Write-Host "Getting AzContext for specific subscription"
Get-AzContext

#Write-Debug $ContainerName
#Write-Debug $RGName
#Write-Debug $SkuVersion

#######################################################################
#### Update Azure Container Registry with required parameters ##############
#######################################################################
function updatecontainerregistry () {
Param (
    
    [Parameter()][string]$RGName,
    [Parameter()][string]$ContainerName,
    [Parameter()][string]$SkuVersion
    
)
Write-Host "Updating the Azure Container Registry from inside function" -ForegroundColor Blue
try {
        $getcontainerregistry = Get-AzContainerRegistry -ResourceGroupName $RGName -Name $ContainerName
        if($getcontainerregistry.ProvisioningState -eq 'Succeeded' ) {
           Write-Host "Updating the container registry $ContainerName" -ForegroundColor Red
            Update-AzContainerRegistry -ResourceGroupName $RGName -Name $ContainerName -Sku $SkuVersion -EnableAdminUser
            Write-Host "Updated Container Registry with latest version" -ForegroundColor Green
            return $True
        }
        else {
           return $False
       }
    }
    catch {
        Write-Host -ForegroundColor DarkCyan " updating azure container registry" $ContainerName "failure" $_.Exception.Message
        Stop-Timer
		Throw $_
    }
    finally {
    Write-Host -ForegroundColor Yellow "Time in Seconds for this function update activity "$stopwatch.Elapsed.TotalSeconds" seconds"  
    }
 }


## MAIN SCRIPT ##

try {
 $containeravailability = Test-AzContainerRegistryNameAvailability -Name $ContainerName
 if ($containeravailability.NameAvailable -eq $True) {
 Write-Host "creating new azure container registry $ContainerName" -ForegroundColor Green
 New-AzContainerRegistry -ResourceGroupName $RGName -Name $ContainerName -Sku $SkuVersion -EnableAdminUser
 Write-Host "Azure container registry created $ContainerName" -ForegroundColor Red
 } else {
 Write-Host "Azure container registry creation failed for $ContainerName" -ForegroundColor Yellow
 }   
 }
 catch {
 Write-Host  -ForegroundColor Yellow   "azure container registry creation failed for this  $ContainerName" $_.Exception.Message
 Write-Host  -ForegroundColor Yellow   " Error in line" $_.InvocationInfo.Line
 Write-Host  -ForegroundColor Yellow   "Error in line number" $_.InvocationInfo.ScriptLineNumber
 Write-Host  -ForegroundColor Yellow   "Error Item Name" $_.Exception.ItemName
 throw $_
 }
 finally {
 Write-Host -ForegroundColor Yellow "Time in Seconds for this activity "$stopwatch.Elapsed.TotalSeconds" seconds"  
  }

Write-Host "Checking if the ACR with this name $ContainerName is existing or not" -ForegroundColor Magenta
Test-AzContainerRegistryNameAvailability  $ContainerName  -Verbose



###  Update Container Registry with SKU versions or Other Parameters ##
Write-Host "If azure container registry already exists then if any new parameters available script will try to update acr with latest parameters" -ForegroundColor Yellow
try {
$containeravailability = Test-AzContainerRegistryNameAvailability -Name $ContainerName
if ($containeravailability -ne $True) {
			
            Write-Host -ForegroundColor Red    "Updating Azure Container Registry with latest version parameters"
			updatecontainerregistry $RGName $ContainerName $SkuVersion
} else {
Write-Host -ForegroundColor Yellow "Updating Container Registry Failed for this specific $ContainerName"
}
}
catch {
 Write-Host  -ForegroundColor Yellow  "azure container registry Update failed for $ContainerName" #$_.Exception.Message 
 throw $_
 }

############################END OF SCRIPT#######################################################