# Development Environment Variables
resource_group_name     = "rg-myapp-dev"
app_service_plan_name   = "asp-myapp-dev"
app_service_name        = "app-myapp-dev"
location                = "East US"
os_type                 = "Linux"
sku_name                = "B1"
always_on               = false
environment             = "dev"

app_settings = {
  "ENVIRONMENT" = "development"
}

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "MyApp"
}
