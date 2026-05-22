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
- Azure DevOps service connection with Contributor + User Access Administrator rights
- Docker Hub image available

## Quick Start

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
