## Provision Azure Container Registry Script ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$rgname,
    [Parameter(Mandatory=$True)][string]$aksname,
    [Parameter(Mandatory=$True)][string]$nodepoolname,
    [Parameter(Mandatory=$True)][string]$intervaltime,    
    [Parameter(Mandatory=$True)][int]$mincount,
    [Parameter(Mandatory=$True)][int]$maxcount
   # [Parameter()][switch]$updatecontainerregistry
    
)
$DebugPreference = 'SilentlyContinue'


## Set Subscription for current working Tenant ##
$SubscriptionId = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
az account list -o table
az account set --subscription $SubscriptionId
Write-Host "Setting the Current Subscription to "TAA-CSO-Axcess_Always-On-Z-NONPRD-Labs" using azcli"
Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext
$currentsubscription = Get-AzContext 
Write-Host "The current Subscription is "$currentsubscription.Subscription.Name" " -ForegroundColor Magenta

if (Get-AzResourceGroup $rgname -ErrorAction SilentlyContinue)
{
az aks update --resource-group $rgname --name $aksname --cluster-autoscaler-profile scan-interval=$intervaltime    
az aks nodepool update --resource-group $rgname --cluster-name $aksname --name $nodepoolname --enable-cluster-autoscaler --min-count $mincount --max-count $maxcount
#az aks update --name $aksname --resource-group $rgname --enable-cluster-autoscaler --min-count $mincount --max-count $maxcount --cluster-autoscaler-profile scan-interval= $intervaltime
}
else
{
Write-Host "Resource group: $rgname doesn't exist."
}