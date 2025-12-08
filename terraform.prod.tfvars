# Production Environment Variables
resource_group_name     = "rg-myapp-prod"
app_service_plan_name   = "asp-myapp-prod"
app_service_name        = "app-myapp-prod"
location                = "East US"
os_type                 = "Linux"
sku_name                = "P1v2"
always_on               = true
environment             = "prod"

app_settings = {
  "ENVIRONMENT" = "production"
}

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "MyApp"
}
