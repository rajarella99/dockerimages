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
    key                  = "agicmarcos.microsoft.tfstate"
    access_key           = "LKueF5xWSmhk/kSsYLtVwQRb+YSDxI2zLwi/LYVa9gpO7E6el2WfuHPtEdv3Za4BOFTpaD1WJkckFl/4UuWRXQ=="
    subscription_id      = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
    tenant_id            = "8ac76c91-e7f1-41ff-a89c-3553b2da2c17"
  }
}

provider "azurerm" {
  features {}
  tenant_id       = "8ac76c91-e7f1-41ff-a89c-3553b2da2c17"
  client_id       = "9900b4b3-2a1b-45ec-952d-ba7a06a5c78d"
  client_secret   = "XEyaPHRTUp.2-a_xxICSkiG_eN5QzH6qpI"
  subscription_id = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
}



#  provider "azurerm" {
#   features {}
#   tenant_id = "8ac76c91-e7f1-41ff-a89c-3553b2da2c17"
#   client_id = "9475f4dc-792b-40c6-b71d-95491b26fb74"
#   client_secret = "NNU7Q~8K8QLdaM6HAUJPIfQid2J9Py4ZqkTw2"
#   subscription_id = "ffed056e-0f97-4b1f-8c93-963008f53d3b"   
# } 