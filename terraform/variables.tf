variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-helm-project"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "greekgod-acr"
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "greekgod-cluster"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VMs in the node pool"
  type        = string
  default     = "Standard_D2s_v3"
}
