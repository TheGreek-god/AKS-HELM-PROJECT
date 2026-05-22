# AKS Helm Deployment Project

End-to-end CI/CD pipeline that provisions Azure infrastructure with Terraform, pushes Docker images to ACR, packages a Helm chart, and deploys to AKS via Azure DevOps.

## Architecture

```
Docker Hub ──> ACR ──> AKS Cluster
                 ↑
          Terraform provisions:
          - Resource Group
          - Container Registry (ACR)
          - Kubernetes Service (AKS)
```

## Pipeline Stages

| Stage | Description |
|-------|-------------|
| **ProvisionInfrastructure** | Terraform init → plan → apply (RG, ACR, AKS) |
| **PushImageToACR** | Pull from Docker Hub, tag, push to ACR |
| **PackageHelm** | Package the Helm chart as an artifact |
| **DeployToAKS** | Download chart, helm upgrade --install to AKS |

## Prerequisites

- Azure subscription
- Docker Hub account with a public image (`greekgod659/starbucks:latest`)
- Azure DevOps organization and project

## Setup Guide (Code Push → Pipeline Run)

### 1. Create Azure DevOps Service Connection

An Azure Resource Manager service connection lets the pipeline authenticate to Azure.

```bash
# In Azure DevOps:
# Project Settings → Service Connections → Create service connection
# Type: Azure Resource Manager
# Scope: Subscription (ce32baea-217e-4d9d-a49c-1e2269fdb999)
# Name: azuredevops-azureportal-service-connection (must match azure-pipelines.yml)
```

> **Required role on the service principal:** `Contributor` + `User Access Administrator` at the subscription scope. The `User Access Administrator` role is needed so Terraform can create the ACR role assignment (`azurerm_role_assignment.aks_acr_pull`).

To assign it via CLI:
```bash
az role assignment create \
  --assignee <service-principal-object-id> \
  --role "User Access Administrator" \
  --scope "/subscriptions/ce32baea-217e-4d9d-a49c-1e2269fdb999"
```

### 2. Push Code to Azure DevOps Repo

```bash
git remote add azure https://dev.azure.com/<org>/<project>/_git/<repo>
git push azure main
```

### 3. Create the Pipeline

1. In Azure DevOps, go to **Pipelines → Create Pipeline**
2. Select **Azure Repos Git** → choose your repo
3. Select **Existing Azure Pipelines YAML File** → pick `azure-pipelines.yml`
4. Click **Run**

### 4. Create the Environment (for deployment approval)

The `DeployToAKS` stage uses `environment: MyAKSCluster`, which creates an approval gate.

1. In Azure DevOps, go to **Pipelines → Environments**
2. Create environment named `MyAKSCluster`
3. Add a manual approval check (optional — you can skip this and the pipeline will proceed automatically)
4. Re-run the pipeline

### 5. Pipeline Stages (What Happens After You Push)

| Stage | Job | What It Does |
|-------|-----|-------------|
| **ProvisionInfrastructure** | TerraformJob | `terraform init` → `plan` → `apply` — creates RG, ACR, AKS |
| **PushImageToACR** | PushImageJob | Pulls `greekgod659/starbucks:latest` from Docker Hub, tags it, pushes to `greekgodacr.azurecr.io/starbucks-app:latest` |
| **PackageHelm** | PackageJob | Packages `helm/my-app` chart → publishes `starbucks-app-<BuildId>.tgz` as pipeline artifact |
| **DeployToAKS** | DeployJob | Downloads chart artifact → `helm upgrade --install starbucks-app-release` to AKS |

### 6. Verify Deployment

```bash
# Get AKS credentials
az aks get-credentials --resource-group rg-aks-helm-project --name greekgodcluster

# Check pods
kubectl get pods

# Get the LoadBalancer IP
kubectl get svc
```

## Quick Start (Local)

```bash
# 1. Provision infrastructure
cd terraform
terraform init
terraform apply -auto-approve

# 2. Push image to ACR
az acr login --name greekgodacr
docker pull greekgod659/starbucks:latest
docker tag greekgod659/starbucks:latest greekgodacr.azurecr.io/starbucks-app:latest
docker push greekgodacr.azurecr.io/starbucks-app:latest

# 3. Deploy Helm chart
helm upgrade --install starbucks-app-release helm/my-app \
  --set image.repository=greekgodacr.azurecr.io/starbucks-app \
  --set image.tag=latest
```

## Resources

- **Resource Group:** `rg-aks-helm-project` (canadacentral)
- **ACR:** `greekgodacr`
- **AKS:** `greekgodcluster` (Standard_D2s_v3, 2 nodes)
- **Namespace:** default

## Clean Up

```bash
cd terraform
terraform destroy -auto-approve
```
