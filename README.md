# Terraform Azure DevOps CI/CD Pipeline

This repository contains Terraform configurations and Azure DevOps pipelines for deploying Azure resources (Resource Group, App Service Plan, and App Service) with environment-specific validation and approval workflows.

## 📁 Project Structure

```
.
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── terraform.dev.tfvars         # Development environment variables
├── terraform.prod.tfvars        # Production environment variables
├── azure-pipelines-ci.yml       # CI Pipeline (Plan)
├── azure-pipelines-cd.yml       # CD Pipeline (Apply)
└── README.md                    # This file
```

## 🚀 Features

### Terraform Configuration
- **Resource Group**: Creates an Azure Resource Group
- **App Service Plan**: Deploys an App Service Plan with configurable SKU
- **App Service**: Deploys either Linux or Windows App Service
- **Environment-specific configurations**: Separate tfvars files for dev and prod
- **Remote state management**: Uses Azure Storage backend

### CI Pipeline (azure-pipelines-ci.yml)
- Installs Terraform
- Authenticates to Azure using Service Connection
- Runs `terraform init`, `fmt`, and `validate`
- **Environment-specific validation**:
  - **Production**: Strict validation, fails on warnings
  - **Development**: Allows warnings, continues execution
- Generates Terraform plan
- Publishes plan and Terraform files as pipeline artifacts

### CD Pipeline (azure-pipelines-cd.yml)
- Downloads plan artifact from CI pipeline
- Authenticates to Azure
- Displays the plan for review
- **Manual approval gate** (configured in Azure DevOps Environment)
- Applies Terraform changes
- Verifies deployment using Azure CLI
- Displays deployment outputs

## 📋 Prerequisites

1. **Azure Subscription**: Active Azure subscription
2. **Azure DevOps Organization**: With a project created
3. **Service Connection**: Azure Resource Manager service connection in Azure DevOps
4. **Service Principal**: With appropriate permissions (Contributor role recommended)
5. **Storage Account**: For Terraform remote state (create manually or via separate script)

## 🔧 Setup Instructions

### 1. Create Azure Storage for Terraform State

```bash
# Variables
RESOURCE_GROUP_NAME="tfstate-rg"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"  # Must be globally unique
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

### 2. Create Service Principal

```bash
az ad sp create-for-rbac --name "terraform-sp" --role Contributor --scopes /subscriptions/{subscription-id}
```

Save the output values (appId, password, tenant).

### 3. Configure Azure DevOps

#### Create Service Connection
1. Go to **Project Settings** > **Service connections**
2. Click **New service connection** > **Azure Resource Manager**
3. Choose **Service principal (manual)**
4. Enter the Service Principal details from step 2
5. Name it (e.g., `azure-service-connection`)

#### Create Pipeline Variables

Create a **Variable Group** named `terraform-variables` with the following variables:

| Variable Name | Value | Secret |
|---------------|-------|--------|
| `azureServiceConnection` | Name of your service connection | No |
| `ARM_CLIENT_ID` | Service Principal App ID | No |
| `ARM_CLIENT_SECRET` | Service Principal Password | Yes |
| `ARM_SUBSCRIPTION_ID` | Your Azure Subscription ID | No |
| `ARM_TENANT_ID` | Your Azure Tenant ID | No |
| `tfStateResourceGroup` | Resource group for state storage | No |
| `tfStateStorageAccount` | Storage account name for state | No |
| `tfStateContainer` | Container name (e.g., `tfstate`) | No |
| `environment` | Target environment (`dev` or `prod`) | No |
| `ciPipelineId` | CI Pipeline ID (set after creating CI pipeline) | No |

#### Create Environments

1. Go to **Pipelines** > **Environments**
2. Create two environments:
   - `dev` (Development)
   - `prod` (Production)
3. For the `prod` environment:
   - Click on the environment
   - Go to **Approvals and checks**
   - Add **Approvals**
   - Add approvers who must approve before deployment

### 4. Create Pipelines

#### CI Pipeline
1. Go to **Pipelines** > **New pipeline**
2. Select your repository
3. Choose **Existing Azure Pipelines YAML file**
4. Select `azure-pipelines-ci.yml`
5. Save and run
6. Note the Pipeline ID (visible in the URL)

#### CD Pipeline
1. Update the `ciPipelineId` variable with the CI Pipeline ID
2. Go to **Pipelines** > **New pipeline**
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select `azure-pipelines-cd.yml`
6. Save (don't run yet)

## 🎯 Usage

### Deploy to Development

1. Update `terraform.dev.tfvars` with your desired configuration
2. Set the `environment` variable to `dev` in your pipeline run
3. Run the **CI Pipeline**
4. Once CI completes, run the **CD Pipeline**
5. The deployment will proceed automatically (no approval required for dev)

### Deploy to Production

1. Update `terraform.prod.tfvars` with your desired configuration
2. Set the `environment` variable to `prod` in your pipeline run
3. Run the **CI Pipeline**
   - Pipeline will perform strict validation
   - Any warnings will cause the pipeline to fail
4. Once CI completes successfully, run the **CD Pipeline**
5. **Manual approval required**: Designated approvers must review and approve
6. After approval, Terraform apply will execute
7. Deployment verification will run automatically

## 🔍 Environment-Specific Validation

### Development Environment
- Standard validation
- Warnings are logged but don't fail the pipeline
- Allows faster iteration and testing

### Production Environment
- Strict validation
- Any warnings cause pipeline failure
- Additional checks for resource deletions
- Requires manual approval before apply

## 📊 Pipeline Outputs

After successful deployment, the CD pipeline displays:
- Resource Group name
- App Service Plan ID
- App Service name
- App Service URL
- Deployment status

## 🛠️ Customization

### Modify Resources

Edit `main.tf` to add or modify Azure resources.

### Add Variables

1. Add variable definition in `variables.tf`
2. Add value in `terraform.dev.tfvars` and `terraform.prod.tfvars`
3. Use the variable in `main.tf`

### Change Validation Logic

Modify the validation step in `azure-pipelines-ci.yml`:

```yaml
- script: |
    # Add your custom validation logic here
  displayName: 'Custom Validation'
```

## 🔐 Security Best Practices

1. **Never commit secrets**: Use Azure DevOps variable groups with secret variables
2. **Use service principals**: Don't use personal accounts for automation
3. **Implement RBAC**: Grant least privilege access
4. **Enable state locking**: Prevents concurrent modifications
5. **Review plans**: Always review Terraform plans before applying
6. **Use manual approvals**: Especially for production environments

## 📝 Troubleshooting

### Common Issues

**Issue**: Terraform init fails with authentication error
- **Solution**: Verify service principal credentials in variable group

**Issue**: Plan artifact not found in CD pipeline
- **Solution**: Ensure CI pipeline completed successfully and `ciPipelineId` is correct

**Issue**: Validation fails in production
- **Solution**: Review warnings, fix issues in Terraform code, and re-run

**Issue**: App Service name already exists
- **Solution**: App Service names must be globally unique. Update `app_service_name` in tfvars

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure DevOps Pipelines Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!
