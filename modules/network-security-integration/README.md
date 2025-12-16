# Check Point Network Security Integration Terraform module for Google Cloud Platform (GCP)

> **Important Notes:**
> - This is a preview release of the CloudGuard Network Security Integration Terraform module for GCP.
>  - The GCP Network Security Integration is currently in private preview.
If you are interested in participating, please reach out to your local Check Point representative. They will contact the Check Point's Cloud Specialist (CSS) or Cloud Architect (CSA) that will gladly enroll you on the Early Availability (EA) program and offer additional documentation and assistance.



This Terraform module deploys Check Point CloudGuard Network Security for the GCP Network Security Integration solution into new or existing VPCs.
As part of the deployment, the following resources are created:

* [Instance Template](https://www.terraform.io/docs/providers/google/r/compute_instance_template.html)
* [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation
* [Instance Group Manager](https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html)
* [Autoscaler](https://www.terraform.io/docs/providers/google/r/compute_region_autoscaler.html)
* [Network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
* [Health Check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_health_check)
* [Backend Service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_region_backend_service)
* [Forwarding Rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule)
* [Intercept Deployment Group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_intercept_deployment_group)
* [Intercept Deployment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_intercept_deployment)
* [Intercept Endpoint Group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_intercept_endpoint_group)
* [Intercept Endpoint Group Association](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_intercept_endpoint_group_association)
* [Security Profile](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_security_profile)
* [Security Profile Group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_security_profile_group)
* [Firewall Policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy)
* [Firewall Policy Rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule)
* [Firewall Policy Association](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_association)


For additional information, see the [CloudGuard Network for GCP Network Security Integration Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_NSI_AG/Default.htm)

## Architecture Layout
![Architecture Layout](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_NSI_AG/Content/Resources/Images/GCP-NSI.png)

## Cross-Zone Deployment
### Intercept Deployment per Availability Zone in the Service VPC
To ensure that traffic is properly intercepted and inspected by Check Point firewalls, an intercept deployment and a corresponding forwarding rule to the Internal Load Balancer must be deployed for each Availability Zone utilized within the Security VPC. 
Note - If an Intercept Deployment is missing in a specific zone, traffic in that zone will bypass GCP Layer 7 policies and not be inspected, resulting in a potential security gap.
These deployments must be aligned with the zones where your workloads reside.
 
Our Terraform template supports a cross-zone deployment model.
Please define the relevant zones using the intercept_deployment_zones parameter in the main.tf file.

Example:
intercept_deployment_zones = ["us-central1-a", "us-central1-b"]

This configuration deploys intercept instances in both us-central1-a and us-central1-b.


## Before you begin
1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/) and set up billing on that project.
2. [Install Terraform] version **1.9.0** (minimum required) or higher, (https://learn.hashicorp.com/tutorials/terraform/install-cli) and read the Terraform Getting Started Guide that follows. This guide will assume basic proficiency with Terraform - it is an introduction to the Google provider.


3. [Create a Service Account](https://cloud.google.com/docs/authentication/getting-started) (or use the existing one). Next, download the JSON key file. Name it something you can remember and store it somewhere secure on your machine. <br/>
4. Ensure that the Service Account possesses the following permissions, in addition to those listed in the main README:
 ```
    compute.firewallPolicies.create
    compute.firewallPolicies.delete
    compute.firewallPolicies.get
    compute.firewallPolicies.update
    compute.firewallPolicies.use
    compute.forwardingRules.create
    compute.forwardingRules.delete
    compute.forwardingRules.get
    compute.forwardingRules.use
    compute.globalOperations.get
    compute.healthChecks.create
    compute.healthChecks.delete
    compute.healthChecks.get
    compute.healthChecks.useReadOnly
    compute.instanceGroups.use
    compute.networks.create
    compute.networks.delete
    compute.networks.setFirewallPolicy
    compute.networks.use
    compute.regionBackendServices.create
    compute.regionBackendServices.delete
    compute.regionBackendServices.use
    compute.regionBackendServices.get
    compute.subnetworks.create
    compute.subnetworks.delete
    compute.zones.list
    networksecurity.interceptDeploymentGroups.create
    networksecurity.interceptDeploymentGroups.delete
    networksecurity.interceptDeploymentGroups.get
    networksecurity.interceptDeploymentGroups.use
    networksecurity.interceptDeployments.create
    networksecurity.interceptDeployments.delete
    networksecurity.interceptDeployments.get
    networksecurity.interceptEndpointGroupAssociations.create
    networksecurity.interceptEndpointGroupAssociations.delete
    networksecurity.interceptEndpointGroupAssociations.get
    networksecurity.interceptEndpointGroups.create
    networksecurity.interceptEndpointGroups.delete
    networksecurity.interceptEndpointGroups.get
    networksecurity.interceptEndpointGroups.use
    networksecurity.securityProfiles.create
```
Add the following Organization level permissions to the service account:
   ```
   Custom roles -  
   networksecurity.securityProfiles.* 
   networksecurity.securityProfileGroups.* 
   networksecurity.operations.get 
   ```
5. Enable the **Network Security API** and **Compute Engine API** for your project. You can do this by either:

   - Running the following `gcloud` commands:
     ```
     gcloud services enable networksecurity.googleapis.com
     ```
     ```
     gcloud services enable compute.googleapis.com
     ```
   - Enabling it manually via the [GCP Console](https://console.cloud.google.com/apis/library).

## Gateway Image Selection

This module supports deployment with the following Check Point CloudGuard gateway images:

### Available Images

| Version | Image Name | License |
|---------|------------|-------------|
| R82 | `check-point-r82-gw-byol-nsi-777-991001897-v20250904` | BYOL |
| R82 | `check-point-r82-gw-payg-nsi-777-991001897-v20250904` | PAYG |
| R81.20 | `check-point-r8120-gw-byol-nsi-631-991001896-v20250903` | BYOL |
| R81.20 | `check-point-r8120-gw-payg-nsi-631-991001896-v20250903` | PAYG |



## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest).
```
provider "google" {
  credentials = "service-accounts/service-account-file-name.json" 
  project     = "project-id"
  region      = "us-central1" 
}

module "nsi-test" {
    source  = "CheckPointSW/cloudguard-network-security/gcp//modules/network-security-integration"
    version = "1.0.6"

    # --- Google Provider ---
    service_account_path              = "service-accounts/service-account-file-name.json"
    project                           = "project-id"                    
    organization_id                   = "1111111111111"

    # --- Check Point---
    prefix                            = "chkp-tf-nsi"
    license                           = "BYOL"
    image_name                        = "check-point-r8120-gw-byol-nsi-631-991001896-v20250903"
    os_version                        = "R8120"
    management_nic                    = "Ephemeral Public IP (eth0)"
    management_name                   = "tf-checkpoint-management"
    configuration_template_name       = "tf-checkpoint-template"
    generate_password                 = true
    admin_SSH_key                     = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    maintenance_mode_password_hash    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    admin_shell                       = "/etc/cli.sh"
    allow_upload_download             = true
    sic_key                           = "xxxxxxxxxxxx"

    # --- Networking ---
    intercept_deployment_zones         = ["us-central1-a"]
    region                            = "us-central1"
    mgmt_network_name                 = ""          
    mgmt_subnetwork_name              = ""      
    mgmt_network_cidr                 = "10.0.4.0/24"
    security_network_name                 = ""  
    security_subnetwork_name              = ""
    security_network_cidr                 = "10.0.5.0/24"
    ICMP_traffic                      = ["123.123.0.0/24", "234.234.0.0/24"]
    TCP_traffic                       = ["0.0.0.0/0"]
    UDP_traffic                       = []
    SCTP_traffic                      = []
    ESP_traffic                       = []
    service_network_name                  = ""
    service_subnetwork_name               = ""
    service_network_cidr                  = "10.0.6.0/24"

    # --- Instance Configuration ---
    machine_type                      = "n1-standard-4"
    cpu_usage                         = 60
    instances_min_group_size          = 2
    instances_max_group_size          = 10
    disk_type                         = "SSD Persistent Disk"
    disk_size                         = 100
    enable_monitoring                 = false
    connection_draining_timeout       = 300
  }
```

## Conditional creation
<br />1. For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.

- If you want to create a new network and subnet, input a subnet CIDR block for the desired new network. In this case, the network name and subnetwork name will not be used:

```
    mgmt_network_name    = "not-use"
    mgmt_subnetwork_name = "not-use"
    mgmt_network_cidr    = "10.0.1.0/24"
```

- Otherwise, if you want to use the existing network and subnet, leave empty double quotes in the CIDR variable for the desired network:

```
    mgmt_network_name    = "network name"
    mgmt_subnetwork_name = "subnetwork name"
    mgmt_network_cidr    = "10.0.1.0/24"
```

<br />2. To create a Firewall and allow traffic for ICMP, TCP, UDP, SCTP, and/or ESP - enter the list of Source IP ranges.
```
ICMP_traffic   = ["123.123.0.0/24", "234.234.0.0/24"]
TCP_traffic    = ["0.0.0.0/0"]
UDP_traffic    = []
SCTP_traffic   = []
ESP_traffic    = []
```
Leave an empty list for a protocol if you want to disable traffic for it.

### Module's variables:
| Name          | Description                                                                                                                                                                                                                                                                                                                                                           | Type          | Allowed values | Default       | Required      |
| ------------- |-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| ------------- | ------------- | ------------- | ------------- |
| service_account_path | User service account path in JSON format - From the service account key page in the Cloud Console, choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location where it is stored. (for example "service-accounts/service-account-name.json") | string  | N/A | "" | yes |
| project  | Personal project ID. The project indicates the default GCP project in which all your resources will be created. The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphens, and cannot end with a hyphen.                                                                                                | string  | N/A | "" | yes
| organization_id | Unique identifier for your organization in GCP. It is used to manage resources and permissions within your organization. [For more detailes](https://cloud.google.com/resource-manager/docs/creating-managing-organization)                                                                                                                                           | string  | N/A | "" | yes
| prefix | (Optional) Resources name prefix. <br/> Note: resource name must not contain reserved words based on [sk40179](https://support.checkpoint.com/results/sk/sk40179).                                                                                                                                                                                                   | string | N/A | "chkp-tf-nsi" | no |
| license | Check Point license (BYOL or PAYG).                                                                                                                                                                                                                                                                                                                                    | string | BYOL <br/> PAYG <br/> | "BYOL" | no |
| image_name | The NSI image name (for example, check-point-r8120-gw-byol-nsi-631-991001896-v20250903).                                                                                                | string | N/A | N/A | yes |
| os_version | Gaia OS Version                                                                                                                                                                                                                                                                                                                                                       | string | R8110;<br/> R8120;<br/> R82; | "R8120" | yes
| management_nic | Management Interface - Autoscaling Security Gateways in GCP can be managed by the ephemeral public IP or by the private IP of the Management interface (eth0).                                                                                                                                                                                                        | string | Ephemeral Public IP (eth0) <br/> Private IP (eth0) | "Ephemeral Public IP (eth0)" | no |
| management_name | The name of the Security Management Server as it appears in the autoprovisioning configuration. (Enter a valid Security Management name including lowercase letters, digits and hyphens only).                                                                                                                                                                        | string | N/A | "checkpoint-management" | no |
| configuration_template_name | Specify the provisioning configuration template name (for autoprovisioning). (Enter a valid autoprovisioning configuration template name including lowercase letters, digits, and hyphens only).                                                                                                                                                                 | string | N/A | "gcp-asg-autoprov-tmplt" | no |
| generate_password  | Automatically generate an administrator password.                                                                                                                                                                                                                                                                                                                     | bool | true <br/>false | false | no |
| admin_SSH_key | Public SSH key for the user 'admin' - The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys.                                                                                                                                                                                         | string | A valid public ssh key | "" | no |
| maintenance_mode_password_hash | Maintenance mode password hash, relevant only for R81.20 and higher versions, to generate a password hash, use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here.                                                                                                                                                                                         | string |  N/A | "" | no |
| admin_shell | Change the admin shell to enable advanced command line configuration.                                                                                                                                                                                                                                                                                                 | string | /etc/cli.sh <br/> /bin/bash <br/> /bin/csh <br/> /bin/tcsh | "/etc/cli.sh" | no |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point.                                                                                                                                                                                                                                            | bool | true/false | true | no |
| region  | GCP region, the gateways will be randomly deployed in zones within the provided region                                                                                                                                                                                                                                                                                   | string  | N/A | "us-central1"  | no |
| intercept_deployment_zones | The zones where the **intercept deployment** will be deployed. Ensure the VMs in the service VPC are created in these zones.                                                                                                                                                                                                                                     | list(string)  | N/A | "us-central1-a"  | no |
| mgmt_network_name | The network determines what network traffic the instance can access.                                                                                                                                                                                                                                                                                                  | string | N/A | N/A | yes |
| mgmt_subnetwork_name | Assigns the instance an IPv4 address from the subnetworkâ€™s range. Instances in different subnetworks can communicate using their internal IP addresses as long as they belong to the same network.                                                                                                                                                             | string | N/A | N/A | yes |
| mgmt_network_cidr | The range of internal addresses that are owned by this network, only IPv4 is supported (for example "10.0.0.0/8" or "192.168.0.0/16").                                                                                                                                                                                                                                       | string | N/A |"10.0.1.0/24" | no|
| security_network_name | The network determines what network traffic the instance can access.                                                                                                                                                                                                                                                                                                  | string | N/A | N/A | yes |
| security_subnetwork_name | Assigns the instance an IPv4 address from the subnetworkâ€™s range. Instances in different subnetworks can communicate using their internal IP addresses as long as they belong to the same network.                                                                                                                                                             | string | N/A | N/A | yes |
| security_network_cidr | The range of internal addresses that are owned by this network, only IPv4 is supported (for example "10.0.0.0/8" or "192.168.0.0/16").                                                                                                                                                                                                                                       | string | N/A |"10.0.2.0/24" | no|
| ICMP_traffic | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Leave an empty list to disable ICMP traffic.                                                                                                                                                           | list(string) | N/A | [] | no |
| TCP_traffic | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Leave an empty list to disable TCP traffic.                                                                                                                                                             | list(string) | N/A | [] | no |
| UDP_traffic | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Leave an empty list to disable UDP traffic.                                                                                                                                                             | list(string) | N/A | [] | no |
| SCTP_traffic | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Leave an empty list to disable SCTP traffic.                                                                                                                                                           | list(string) | N/A | [] | no |
| ESP_traffic | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Leave an empty list to disable ESP traffic.                                                                                                                                                             | list(string) | N/A | [] | no |
| service_network_name | The network determines which network the Web VM will be deployed on and where the intercept endpoint group association will be deployed.                                                                                                                                                                                                                             | string | N/A | N/A | yes |
| service_subnetwork_name | Assigns the instance an IPv4 address from the subnetworkâ€™s range. Instances in different subnetworks can communicate using their internal IP addresses as long as they belong to the same network.                                                                                                                                                             | string | N/A | N/A | yes |
| service_network_cidr | The range of internal addresses that are owned by this network, only IPv4 is supported (for example "10.0.0.0/8" or "192.168.0.0/16").                                                                                                                                                                                                                                       | string | N/A |"10.0.2.0/24" | no|
| machine_type | Machine Type.                                                                                                                                                                                                                                                                                                                                                         | string | N/A | "n1-standard-4" | no |
| cpu_usage | Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance.                                                                                                                                                                                                                                       | number | number between 10 and 90 | 60 | no |
| instances_min_group_size | The minimal number of instances                                                                                                                                                                                                                                                                                                                                       | number | N/A | 2 | no |
| instances_max_group_size | The maximal number of instances                                                                                                                                                                                                                                                                                                                                       | number | N/A | 10 | no |
| disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency.                                                                                                                                                                                                       | string | SSD Persistent Disk <br/> Balanced Persistent Disk <br/> Standard Persistent Disk | "SSD Persistent Disk" | no |
| disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space.                                                                                                                                                                                                     | number | number between 100 and 4096 | 100 | no |
| enable_monitoring | Enable Stackdriver monitoring                                                                                                                                                                                                                                                                                                                                         | bool | true <br/> false | false | no |
| connection_draining_timeout | The time, in seconds, that the load balancer waits for active connections to complete before fully removing an instance from the backend group.                                                                                                                                                                                                                                                     | number | N/A | 300 | no |