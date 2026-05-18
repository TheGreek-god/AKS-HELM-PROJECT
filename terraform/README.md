# Terraform Infrastructure for AKS Helm Project

## Prerequisites
- Azure CLI installed and authenticated (`az login`)
- Terraform installed

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Customize variables (optional)**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   # Note: ACR name must be globally unique
   ```

3. **Plan deployment**
   ```bash
   terraform plan
   ```

4. **Deploy infrastructure**
   ```bash
   terraform apply
   ```

5. **Configure kubectl**
   ```bash
   az aks get-credentials --resource-group rg-aks-helm-project --name aks-helm-project
   ```

6. **Build and push Docker image to ACR**
   ```bash
   az acr login --name acrakshelmproject
   docker build -t acrakshelmproject.azurecr.io/my-app:latest ./app
   docker push acrakshelmproject.azurecr.io/my-app:latest
   ```

## Resources Created
- Resource Group
- Azure Container Registry (ACR) with AcrPull role for AKS
- Azure Kubernetes Service (AKS) cluster with 2 nodes
- Network configuration with Azure CNI

## Clean Up
```bash
terraform destroy
```
