variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "os_type" {
  description = "OS type for App Service Plan (Linux or Windows)"
  type        = string
  default     = "Linux"
  
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "sku_name" {
  description = "SKU name for App Service Plan"
  type        = string
  default     = "B1"
}

variable "always_on" {
  description = "Should the app be loaded at all times"
  type        = bool
  default     = false
}

variable "app_settings" {
  description = "App settings for the App Service"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}
