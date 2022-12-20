terraform {

    required_version = ">=0.12"
  
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "~>2.0"
      }
    }
    backend "azurerm" {
      resource_group_name  = "marcos"
      storage_account_name = "rajdevops"
      container_name       = "telemetry"
      key                  = "codelab.microsoft.tfstate"
      access_key = "LKueF5xWSmhk/kSsYLtVwQRb+YSDxI2zLwi/LYVa9gpO7E6el2WfuHPtEdv3Za4BOFTpaD1WJkckFl/4UuWRXQ=="
      subscription_id = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
      tenant_id = "8ac76c91-e7f1-41ff-a89c-3553b2da2c17"
    } 
  }
  
  provider "azurerm" {
    features {}
  }