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
   az aks get-credentials --resource-group rg-aks-helm-project --name greekgodcluster
   ```

6. **Build and push Docker image to ACR**
   ```bash
   az acr login --name greekgodacr
   docker build -t greekgodacr.azurecr.io/starbucks-app:latest ./app
   docker push greekgodacr.azurecr.io/starbucks-app:latest
   ```

## Resources Created
- Resource Group: `rg-aks-helm-project` (canadacentral)
- Azure Container Registry: `greekgodacr`
- Azure Kubernetes Service: `greekgodcluster` (2x Standard_D2s_v3, Azure CNI)
- AcrPull role assignment for AKS to ACR

## Clean Up
```bash
terraform destroy
```
