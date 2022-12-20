[CmdletBinding()]
Param (
	
	[Parameter(Mandatory=$True)][string]$VMName,
	[Parameter(Mandatory=$True)][string]$version,
	[Parameter(Mandatory=$True)][string]$ResourceGroupName,
	[Parameter(Mandatory=$True)][string]$dcPassword,
	[Parameter(Mandatory=$True)][string]$Location,
	[Parameter(Mandatory=$True)][string]$StorageAccountName,
	[Parameter(Mandatory=$True)][string]$StorageAccountKey,
	[Parameter(Mandatory=$True)][string]$ContainerName
    #[Parameter()][switch]$defaultversion
)

## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$OTELExtName = 'otelserviceinstallation'

## Set Subscription for current working Tenant ##
$SubscriptionId = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext
$currentsubscription = Get-AzContext 
Write-Host "The current Subscription is "$currentsubscription.Subscription.Name" " -ForegroundColor Magenta

#$default = 33

$vmStatuses = $(Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status).Statuses

if ($vmStatuses.DisplayStatus[$vmStatuses.DisplayStatus.Count - 1] -eq 'VM running') {
	## Azure custom script extension to run and execute cmdlets to install otel collector service on windows machines on Azure cloud## 
	Write-Output "Install OTEL Service on remote machine"
	$params = @{
		ResourceGroupName =		$ResourceGroupName
		Location =				$Location
		VMName =				$VMname
		Name = 					$OTELExtName
		StorageAccountName =	$StorageAccountName
		StorageAccountKey =		$StorageAccountKey
		FileName =				"telemetry-main.ps1"
		Run =					"telemetry-main.ps1"
		Argument =				"$version"
		ContainerName =			$StorageContainerName
	}
	Set-AzVMCustomScriptExtension @params
	Start-Sleep -Seconds 90 -Verbose
	$otelextension = Get-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -VMName $VMname -Name $OTELExtName
}
if ($otelextension.ProvisioningState -ne 'Failed') {
	## Remove Azure custom script extensioin after job completes##
	Start-Sleep -Seconds 10 -Verbose 
	Write-Output "Removing CS extention in after OTEL COLLECTOR SERVICE INSTALLATION."
	Remove-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -VMName $VMname -Name $OTELExtName -Force
} else {
	Write-Error -Message "Custom script did not execute corretly!"
	Exit
}