terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Backend configuration will be provided via pipeline variables
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstatestorage"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  
  tags = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = var.os_type
  sku_name            = var.sku_name
  
  tags = var.tags
}

# App Service
resource "azurerm_linux_app_service" "main" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_service_plan.main.id
  
  site_config {
    always_on = var.always_on
  }
  
  app_settings = var.app_settings
  
  tags = var.tags
}

resource "azurerm_windows_app_service" "main" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_service_plan.main.id
  
  site_config {
    always_on = var.always_on
  }
  
  app_settings = var.app_settings
  
  tags = var.tags
}
