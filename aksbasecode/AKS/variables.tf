variable "resource_group_name_prefix" {
    default       = "akstelemetry"
    description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  }
  
  variable "resource_group_location" {
    default       = "centralus"
    description   = "Location of the resource group."
  }
  
  variable "agent_count" {
      default = 1
  }
  
#   variable "ssh_public_key" {
#       default = "~/.ssh/id_rsa.pub"
#   }
  
  variable "dns_prefix" {
      default = "telemetry"
  }

  variable "acr_id" {
      default = "/subscriptions/ffed056e-0f97-4b1f-8c93-963008f53d3b/resourceGroups/marcos/providers/Microsoft.ContainerRegistry/registries/wkmarcosyard"
  }  
  
  variable "aks_service_principal_app_id" {
    description = "Application ID/Client ID  of the service principal. Used by AKS to manage AKS related resources on Azure like vms, subnets."
  }
  
  variable "aks_service_principal_client_secret" {
    description = "Secret of the service principal. Used by AKS to manage Azure."
  }
  
  variable "aks_service_principal_object_id" {
    description = "Object ID of the service principal."
  }
  
  variable cluster_name {
      default = "marcos-agic-test"
  }
  
  variable resource_group_name {
      default = "DefaultResourceGroup-NCUS"
  }
  
  variable location {
      default = "Central US"
  }
  
  variable log_analytics_workspace_name {
      default = "marcos-telemetry-loganalyticsworkspace"
  }
  
  # refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
  variable log_analytics_workspace_location {
      default = "North Central US"
  }
  
  # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
  variable log_analytics_workspace_sku {
      default = "PerGB2018"
  }