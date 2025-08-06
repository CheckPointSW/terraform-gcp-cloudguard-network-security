![GitHub Wachers](https://img.shields.io/github/watchers/CheckPointSW/terraform-azure-cloudguard-network-security)
![GitHub Release](https://img.shields.io/github/v/release/CheckPointSW/terraform-azure-cloudguard-network-security)
![GitHub Commits Since Last Commit](https://img.shields.io/github/commits-since/CheckPointSW/terraform-azure-cloudguard-network-security/latest/master)
![GitHub Last Commit](https://img.shields.io/github/last-commit/CheckPointSW/terraform-azure-cloudguard-network-security/master)
![GitHub Repo Size](https://img.shields.io/github/repo-size/CheckPointSW/terraform-azure-cloudguard-network-security)
![GitHub Downloads](https://img.shields.io/github/downloads/CheckPointSW/terraform-azure-cloudguard-network-security/total)

# Terraform Modules for CloudGuard Network Security (CGNS) - GCP


## Introduction
This repository provides a structured set of Terraform modules for deploying Check Point CloudGuard Network Security in GCP. These modules automate the creation of Virtual Networks, Security Gateways, High-Availability architectures, and more, enabling secure and scalable cloud deployments.


## Before you begin
1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/) and set up billing on that project.
2. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and read the Terraform getting started guide that follows. This guide will assume basic proficiency with Terraform - it is an introduction to the Google provider.

### Configuring the Provider
The **main.tf** file includes the following provider configuration block used to configure the credentials you use to authenticate with GCP, as well as a default project and location for your resources:
```
provider "google" {
  credentials = file(var.service_account_path)
  project     = var.project
  region      = var.region
}
...
```

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
3. ```credentials``` - Your service account key file is used to complete a two-legged OAuth 2.0 flow to obtain access tokens to authenticate with the GCP API as needed; Terraform will use it to reauthenticate automatically when tokens expire. <br/> 
The provider credentials can be provided either as static credentials or as [Environment Variables](https://www.terraform.io/docs/providers/google/guides/provider_reference.html#credentials-1).
    - Static credentials can be provided by adding the path to your service-account json file, project-id and region in /gcp/modules/autoscale-into-new-vpc/**terraform.tfvars** file as follows:
        ```
        service_account_path = "service-accounts/service-account-file-name.json"
        project = "project-id"
        region = "us-central1"
        ```
     - In case the Environment Variables are used, perform modifications described below:<br/>
        a. The next lines in the main.tf file, in the provider google resource, need to be deleted or commented:
        ```
        provider "google" {
          //  credentials = file(var.service_account_path)
          //  project = var.project
       
          region = var.region
        }
       ```
       b.In the terraform.tfvars file leave empty double quotes for credentials and project variables:
       ```
       service_account_path = ""
       project = ""
       ```
## Usage
- Fill all variables in the /gcp/autoscale-into-existing-vpc/**terraform.tfvars** file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:
    ```
    terraform init
    ```
- Create an execution plan:
    ```
    terraform plan
    ```
- Create or modify the deployment:
    ```
    terraform apply
    ```

## Repository Structure
`Submodules:` Contains modular, reusable, production-grade Terraform components, each with its own documentation.

`Examples:` Demonstrates how to use the modules.

 
**Submodules:**
* [`network-security-integration`](https://registry.terraform.io/modules/chkp-olgami/olgami/gcp/latest/submodules/network-security-integration) - Deploys GCP Network Security Integration.

Internal Submodules - 

* [`firewall-rule`](https://registry.terraform.io/modules/chkp-olgami/olgami/gcp/latest/submodules/firewall-rule) - Deploys firewall rules on GCP VPCs.
* [`internal-load-balancer`](https://registry.terraform.io/modules/chkp-olgami/olgami/gcp/latest/submodules/internal-load-balancer) - Deploys internal load balanncer.
* [`network-and-subnet`](https://registry.terraform.io/modules/chkp-olgami/olgami/gcp/latest/submodules/network-and-subnet) - Deploys VPC and subnetwork in the VPC.
* [`network-security-integration-common`](https://registry.terraform.io/modules/chkp-olgami/olgami/gcp/latest/submodules/network-security-integration-common) - Deploys Network Security Integration.


***

# Best Practices for Using CloudGuard Modules

## Step 1: Use the Required Module
Add the required module in your Terraform configuration file (`main.tf`) to deploy resources. For example:

```hcl
provider "google" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/gcp//modules/{module_name}"
  version = "{chosen_version}"
  # Add the required inputs
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
