![GitHub Wachers](https://img.shields.io/github/watchers/CheckPointSW/terraform-gcp-cloudguard-network-security)
![GitHub Release](https://img.shields.io/github/v/release/CheckPointSW/terraform-gcp-cloudguard-network-security)
![GitHub Commits Since Last Commit](https://img.shields.io/github/commits-since/CheckPointSW/terraform-gcp-cloudguard-network-security/latest/master)
![GitHub Last Commit](https://img.shields.io/github/last-commit/CheckPointSW/terraform-gcp-cloudguard-network-security/master)
![GitHub Repo Size](https://img.shields.io/github/repo-size/CheckPointSW/terraform-gcp-cloudguard-network-security)
![GitHub Downloads](https://img.shields.io/github/downloads/CheckPointSW/terraform-gcp-cloudguard-network-security/total)

# Terraform Modules for CloudGuard Network Security (CGNS) - GCP


## Introduction
This repository provides a structured set of Terraform modules for deploying Check Point CloudGuard Network Security in GCP. These modules automate the creation of Virtual Networks, Security Gateways, High-Availability architectures, and more, enabling secure and scalable cloud deployments.


## Before you begin
1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/) and set up billing on that project.
2. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and read the Terraform getting started guide that follows. This guide will assume basic proficiency with Terraform - it is an introduction to the Google provider.

### Configuring the Provider
1. [Create a Service Account](https://cloud.google.com/docs/authentication/getting-started) (or use the existing one). Next, download the JSON key file. Name it something you can remember and store it somewhere secure on your machine. <br/>
2. Select "Editor" Role or verify you have the following permissions:
   ```
   compute.autoscalers.create
   compute.autoscalers.delete
   compute.autoscalers.get
   compute.autoscalers.update
   compute.disks.create
   compute.firewalls.create
   compute.firewalls.delete
   compute.firewalls.get
   compute.firewalls.update
   compute.instanceGroupManagers.create
   compute.instanceGroupManagers.delete
   compute.instanceGroupManagers.get
   compute.instanceGroupManagers.use
   compute.instanceGroups.delete
   compute.instanceTemplates.create
   compute.instanceTemplates.delete
   compute.instanceTemplates.get
   compute.instanceTemplates.useReadOnly
   compute.instances.create
   compute.instances.setMetadata
   compute.instances.setTags
   compute.networks.get
   compute.networks.updatePolicy
   compute.regions.list
   compute.subnetworks.get
   compute.subnetworks.use
   compute.subnetworks.useExternalIp
   iam.serviceAccounts.actAs
   ```
3. Configure the provider in your `main.tf` file. Your service account key file is used to complete a two-legged OAuth 2.0 flow to obtain access tokens to authenticate with the GCP API as needed; Terraform will use it to reauthenticate automatically when tokens expire. <br/> 
The provider credentials can be provided either as static credentials or as [Environment Variables](https://www.terraform.io/docs/providers/google/guides/provider_reference.html#credentials-1).
    - **Static credentials**: Specify the path to your service account key file in your `main.tf`:
    
        ```hcl
        provider "google" {
          credentials = "path/to/service-account-key.json"
          project     = "your-project-id"
          region      = "your-region"
        }
        ```
    
    - **Environment Variables**: If you prefer to use environment variables (e.g., `GOOGLE_APPLICATION_CREDENTIALS`, `GOOGLE_PROJECT`), you can omit credentials and project from the provider block:
        
        ```hcl
        provider "google" {
          region = "your-region"
        }
        ```

## Repository Structure
`Submodules:` Contains modular, reusable, production-grade Terraform components, each with its own documentation.

`Examples:` Demonstrates how to use the modules.

 
**Submodules:**
* [`single`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/single) - Deploys a single Check Point Security Gateway or Management Server.
* [`cluster`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/cluster) - Deploys a Check Point Security Gateway cluster (high availability).
* [`autoscale`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/autoscale) - Deploys Check Point Security Gateways with auto-scaling capabilities.
* [`network-security-integration`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/network-security-integration) - Deploys GCP Network Security Integration.

Internal Submodules - 

* [`firewall-rule`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/firewall-rule) - Deploys firewall rules on GCP VPCs.
* [`internal-load-balancer`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/internal-load-balancer) - Deploys internal load balanncer.
* [`network-and-subnet`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/network-and-subnet) - Deploys VPC and subnetwork in the VPC.
* [`network-security-integration-common`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/network-security-integration-common) - Deploys Network Security Integration.
* [`compute-image`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest/submodules/computes-image) - Deploy using last image to OS version.


***

# Best Practices for Using CloudGuard Modules

## Step 1: Use the Required Module
Add the required module in your Terraform configuration file (`main.tf`) to deploy resources. For example:

```hcl
provider "google" {
  credentials = "path/to/service-account-key.json"
  project     = "your-project-id"
  region      = "your-region"
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/gcp//modules/{module_name}"
  version = "{chosen_version}"
  // Add the required inputs
}
```
---

## Step 2: Deploy with Terraform
Use Terraform commands to deploy resources securely.

### Initialize Terraform
Prepare the working directory and download required provider plugins:
```hcl
terraform init
```

### Plan Deployment
Preview the changes Terraform will make:
```hcl
terraform plan
```
### Apply Deployment
Apply the planned changes and deploy the resources:
```hcl
terraform apply
```
