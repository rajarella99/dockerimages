variable "resource_group_name_prefix" {
  default     = "agic"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default     = "centralus"
  description = "Location of the resource group."
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

variable "aks_user_id" {
  description = "Email id of the AAD User Account."
}

# variable "aks_managed_identity_id" {
#   description = "Email id of the AAD User Account."
# }  

variable "virtual_network_name" {
  description = "Virtual network name"
  default     = "aks-vnet-clustervnet" #aksVirtualNetwork
}

variable "virtual_network_address_prefix" {
  description = "VNET address prefix"
  default     = "192.168.0.0/16"
}

variable "aks_subnet_name" {
  description = "Subnet Name."
  default     = "kubesubnet"
}

variable "aks_subnet_address_prefix" {
  description = "Subnet address prefix."
  default     = "192.168.0.0/24"
}

variable "app_gateway_subnet_address_prefix" {
  description = "Subnet server IP address."
  default     = "192.168.1.0/24"
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  default     = "ApplicationGateway1"
}

variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU"
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway tier"
  default     = "Standard_v2"
}

variable "aks_name" {
  description = "AKS cluster name"
  default     = "marcos-agic-ingress"
}
variable "aks_dns_prefix" {
  description = "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
  default     = "telemetry"
}

variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
  default     = 128
}

variable "aks_agent_count" {
  description = "The number of agent nodes for the cluster."
  default     = 1
}

variable "aks_agent_vm_size" {
  description = "VM size"
  default     = "Standard_D2_v2"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  default     = "1.21.9"
}

variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS server IP address"
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC on the AKS cluster. Defaults to false."
  default     = "true"
}

variable "vm_user_name" {
  description = "User name for the VM"
  default     = "vmuser1"
}

variable "public_ssh_key_path" {
  description = "Public key path for SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
  }
}


variable "log_analytics_workspace_name" {
  default = "marcos-telemetry-loganalyticsworkspace"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "North Central US"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}