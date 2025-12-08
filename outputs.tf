output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.main.id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_app_service.main[0].name : azurerm_windows_app_service.main[0].name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_app_service.main[0].default_site_hostname : azurerm_windows_app_service.main[0].default_site_hostname
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = var.os_type == "Linux" ? "https://${azurerm_linux_app_service.main[0].default_site_hostname}" : "https://${azurerm_windows_app_service.main[0].default_site_hostname}"
}
