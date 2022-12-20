#Generate random resource group name
resource "random_pet" "rg-name" {
    prefix    = var.resource_group_name_prefix
  }
  
  resource "azurerm_resource_group" "rg" {
    name      = random_pet.rg-name.id
    location  = var.resource_group_location
  }

# Install inside existing resource group
# data "azurerm_resource_group" "azrg" {
#   name = "marcos"
# }

# output "id" {
#   value = data.azurerm_resource_group.azrg.id
# }
  
# AKS to ACR Role Assignment
# data "azurerm_container_registry" "acr_name" {
#   name = "myacr"
#   resource_group_name = "acr-resource-group"
# }

# data "azuread_service_principal" "aks_principal" {
#   application_id = var.aks_service_principal_client_id
# }

# resource "azurerm_role_assignment" "acrpull_role" {
#   scope                            = azurerm_container_registry.acr.id
#   role_definition_name             = "AcrPull"
#   principal_id                     = data.azuread_service_principal.aks_principal.id
#   skip_service_principal_aad_check = true
# }


  
  resource "random_id" "log_analytics_workspace_name_suffix" {
      byte_length = 8
  }
  
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  resource "azurerm_log_analytics_workspace" "test" {      
      name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
      location            = var.log_analytics_workspace_location
      resource_group_name = azurerm_resource_group.rg.name
      sku                 = var.log_analytics_workspace_sku
  }
  
  resource "azurerm_log_analytics_solution" "test" {
      solution_name         = "ContainerInsights"
      location              = azurerm_log_analytics_workspace.test.location
      resource_group_name   = azurerm_resource_group.rg.name
      workspace_resource_id = azurerm_log_analytics_workspace.test.id
      workspace_name        = azurerm_log_analytics_workspace.test.name
  
      plan {
          publisher = "Microsoft"
          product   = "OMSGallery/ContainerInsights"
      }
  }
  
  resource "azurerm_kubernetes_cluster" "rg" {
      name                = var.cluster_name
      location            = azurerm_resource_group.rg.location
      resource_group_name = azurerm_resource_group.rg.name
      dns_prefix          = var.dns_prefix
    #   enable_attach_acr   = true
    #   acr_id = var.acr_id  
      oms_agent {
          log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id        
      }
  
    #   linux_profile {
    #       admin_username = "ubuntu"
  
    #     #   ssh_key {
    #     #       key_data = file(var.ssh_public_key)
    #     #   }
    #   }
  
      default_node_pool {
          name            = "agentpool"
          node_count      = var.agent_count
          vm_size         = "Standard_D2_v2"
      }
  
      service_principal {
          client_id     = var.aks_service_principal_app_id
          client_secret = var.aks_service_principal_client_secret
      }
  
    #   addon_profile {
    #       oms_agent {
    #       enabled                    = true
    #       log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    #       }
    #   }
  
      network_profile {
          load_balancer_sku = "Standard"
          network_plugin = "kubenet"
      }
  
      tags = {
          Environment = "Development"
      }
  }