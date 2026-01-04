# Check Point Network Security Integration Terraform module for Google Cloud Platform (GCP)

## Overview

This Terraform module deploys Check Point CloudGuard Network Security for the GCP Network Security Integration solution into new or existing VPCs.

For additional information, see the [CloudGuard Network for GCP Network Security Integration Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_NSI_AG/Default.htm)

## Architecture
![NSI Architecture](https://raw.githubusercontent.com/CheckPointSW/terraform-gcp-cloudguard-network-security/master/modules/network-security-integration/nsi-architecture.png)

## Cross-Zone Deployment

An intercept deployment and corresponding forwarding rule to the Internal Load Balancer must be deployed for each Availability Zone where your workloads reside. This ensures that traffic in all zones is properly intercepted and inspected by the Check Point gateways.

If an Intercept Deployment is missing in a specific zone, traffic in that zone will bypass the inspection layer entirely, creating a security gap. Therefore, it is critical to align the intercept deployment zones with the zones where your workloads are deployed.

The `intercept_deployment_zones` parameter controls which zones receive intercept deployments:

```
intercept_deployment_zones = ["us-central1-a", "us-central1-b"]
```

This example deploys intercept instances in both `us-central1-a` and `us-central1-b`.


## Before you begin
1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/) and set up billing on that project.
2. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) version **1.9.0** (minimum required) or higher, and read the Terraform Getting Started Guide that follows. This guide will assume basic proficiency with Terraform - it is an introduction to the Google provider.

---

## Producer Deployment (Terraform)

This section covers deploying the Check Point CloudGuard Network Security for the GCP Network Security Integration solution using Terraform.

### Service Account Permissions

<details>
<summary><b>Click to view required permissions</b></summary>

Ensure that the Service Account used for Terraform deployment possesses the following permissions:

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
```

</details>

## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/gcp/latest).


```hcl
provider "google" {
  credentials = "service-accounts/service-account-file-name.json"
  project     = "project-id"
  region      = "us-central1"
}

module "nsi_producer" {
  source  = "CheckPointSW/cloudguard-network-security/gcp//modules/network-security-integration"
  version = "~> 1.0"

  # --- Google Provider ---
  project = "project-id"

  # --- Check Point CloudGuard Configuration ---
  prefix                         = "chkp-tf-nsi"
  management_name                = "tf-checkpoint-management"
  configuration_template_name    = "tf-checkpoint-template"
  sic_key                        = "xxxxxxxxxxxx"
  management_nic                 = "Ephemeral Public IP (eth0)"
  generate_password              = true
  admin_SSH_key                  = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  admin_shell                    = "/etc/cli.sh"
  allow_upload_download          = true

  # --- Check Point Image ---
  source_image = ""
  os_version   = "R82"
  license      = "BYOL"

  # --- Region and Zones ---
  region                     = "us-central1"
  intercept_deployment_zones = ["us-central1-a"]

  # --- Management VPC ---
  mgmt_network_cidr    = "10.0.4.0/24"
  mgmt_network_name    = ""
  mgmt_subnetwork_name = ""

  # --- Security VPC ---
  security_network_cidr    = "10.0.5.0/24"
  security_network_name    = ""
  security_subnetwork_name = ""

  # --- Management VPC Firewall Rules ---
  mgmt_network_icmp_traffic = "0.0.0.0/0"
  mgmt_network_tcp_traffic  = "0.0.0.0/0"
  mgmt_network_udp_traffic  = ""
  mgmt_network_sctp_traffic = ""
  mgmt_network_esp_traffic  = ""

  # --- Autoscaling Configuration ---
  machine_type                = "n1-standard-4"
  cpu_usage                   = 60
  instances_min_group_size    = 2
  instances_max_group_size    = 10
  disk_type                   = "SSD Persistent Disk"
  disk_size                   = 100
  enable_monitoring           = false
  connection_draining_timeout = 300
}
```


## VPC
For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.

**If you want to create a new network and subnet**, please input a subnet CIDR block for the desired new network:

```
mgmt_network_cidr    = "10.0.1.0/24"
mgmt_network_name    = ""       # Leave empty when creating new VPC
mgmt_subnetwork_name = ""       # Leave empty when creating new VPC
```

**If you want to use an existing network and subnet**, please leave the CIDR variable empty and specify the network names:

```
mgmt_network_cidr    = ""       # Leave empty when using existing VPC
mgmt_network_name    = "existing-network-name"
mgmt_subnetwork_name = "existing-subnet-name"
```

## Firewall Rules
To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter comma-separated list of Source IP ranges.

```
mgmt_network_icmp_traffic = "123.123.0.0/24, 234.234.0.0/24"
mgmt_network_tcp_traffic  = "0.0.0.0/0"
mgmt_network_udp_traffic  = ""
mgmt_network_sctp_traffic = ""
mgmt_network_esp_traffic  = ""
```

Please leave empty `""` for a protocol if you want to disable traffic for it.

## Images
You can choose to either deploy with the latest image or with a custom image.

**If you want to deploy with the latest image**, leave the `source_image` empty or with `"latest"` keyword and specify the `os_version` and `license`:

```
source_image = ""       # Leave empty for latest image
os_version   = "R82"
license      = "BYOL"
```

**If you want to deploy with a specific image**, specify the `source_image` with the path to the image:

```
source_image = "check-point-r82-gw-byol-nsi-777-991001866-v20250731"
os_version   = ""       # Leave empty when specifying a custom image
license      = ""       # Leave empty when specifying a custom image
```

To get the list of images per solution:
1. Download and install [`gcloud cli`](https://cloud.google.com/sdk/docs/install-sdk).
2. Make sure you are logged in using `gcloud auth login`.
3. Run for:<br/>
    `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-gw-LICENSE-nsi-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`

    Replace:
    - `VERSION` with either `r8120`, `r82` or `r8210`.
    - `LICENSE` with either `byol` or `payg`.
4. Choose the image name you wan't. Note that the newest one are the top of the list.


## Management and CME Configuration

After the successful Terraform deployment, you should connect to the Security Management Server and configure the Cloud Management Extension (CME) to manage the autoscaling gateways. For detailed instructions on how to configure the Security Management Server and CME, please refer to the following guides:

- [Installing a Check Point Security Management Server](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_NSI_AG/Content/Topics-GCP-NSI-AG/Deployment-and-Configuration.htm?tocpath=_____10)
- [Configuring CME on Management Server](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_NSI_AG/Content/Topics-GCP-NSI-AG/Configuring_CME__on_Management_Server.htm?tocpath=_____11)

---

## Consumer Deployment

After deploying the NSI producer infrastructure with Terraform, configure your consumer VPC(s) to use the inspection service using `gcloud` commands.

> **Important Note:**  
> VPC firewall rules should not be used in consumer VPCs protected by NSI. VPC firewall rules have higher enforcement priority than global network firewall policies, which can cause traffic to bypass inspection. Use Network Firewall Policies (configured in the steps below) instead of VPC firewall rules to ensure all traffic is properly inspected.

### Prerequisites

Before proceeding with the consumer setup, ensure the Network Security API is enabled for your consumer project:

```bash
gcloud services enable networksecurity.googleapis.com
```

Alternatively, you can enable this API manually via the [GCP Console](https://console.cloud.google.com/apis/library).

### Service Account Permissions

<details>
<summary><b>Click to view required permissions</b></summary>

For the manual consumer setup, ensure the user/service account has the following permissions:

**Project-level permissions (consumer project):**
```
compute.firewallPolicies.create
compute.firewallPolicies.delete
compute.firewallPolicies.get
compute.firewallPolicies.update
compute.firewallPolicies.use
compute.networks.setFirewallPolicy
networksecurity.interceptEndpointGroups.create
networksecurity.interceptEndpointGroups.delete
networksecurity.interceptEndpointGroups.get
networksecurity.interceptEndpointGroups.use
networksecurity.interceptEndpointGroupAssociations.create
networksecurity.interceptEndpointGroupAssociations.delete
networksecurity.interceptEndpointGroupAssociations.get
networksecurity.securityProfiles.create
```

**Organization-level permissions:**
```
networksecurity.securityProfiles.*
networksecurity.securityProfileGroups.*
networksecurity.operations.get
```

</details>

### Step 1: Set Environment Variables

Set the following environment variables with your deployment values. These will be used throughout the consumer setup process.

#### Required Values

| Value | Environment Variable | Example | How to Obtain |
|-------|---------------------|---------|---------------|
| Producer Project ID | `$PRODUCER_PROJECT` | `my-producer-project` | `gcloud projects list` |
| Consumer Project ID | `$CONSUMER_PROJECT` | `my-consumer-project` | `gcloud projects list` |
| Organization ID | `$ORG_ID` | `123456789012` | `gcloud projects describe $PRODUCER_PROJECT --format="value(parent.id)"`|
| Prefix (from Terraform) | `$PREFIX` | `chkp-tf-nsi` | The prefix value used in your Terraform deployment |
| Intercept Deployment Group | `$INTERCEPT_DEPLOYMENT_GROUP` | `projects/my-producer-project/locations/global/interceptDeploymentGroups/chkp-tf-nsi-intercept-deployment-group` | `gcloud network-security intercept-deployment-groups list --project=$PRODUCER_PROJECT --location=global`<br/>Or construct: `projects/$PRODUCER_PROJECT/locations/global/interceptDeploymentGroups/$PREFIX-intercept-deployment-group` |
| Consumer VPC Name | `$CONSUMER_VPC` | `my-workload-vpc` | `gcloud compute networks list --project=$CONSUMER_PROJECT` |

#### Set the Variables

```bash
export PRODUCER_PROJECT="your-producer-project-id"
export CONSUMER_PROJECT="your-consumer-project-id"
export ORG_ID="your-organization-id"
export PREFIX="your-terraform-prefix"
export INTERCEPT_DEPLOYMENT_GROUP="projects/$PRODUCER_PROJECT/locations/global/interceptDeploymentGroups/$PREFIX-intercept-deployment-group"
export CONSUMER_VPC="your-consumer-vpc-name"
```

---

### Step 2: Create Intercept Endpoint Group

The Intercept Endpoint Group acts as the connection point between your consumer VPC and the producer's inspection service. It references the Intercept Deployment Group created by the Terraform module in the producer project.

```bash
gcloud network-security intercept-endpoint-groups create consumer-intercept-epg \
    --project=$CONSUMER_PROJECT \
    --location=global \
    --intercept-deployment-group=$INTERCEPT_DEPLOYMENT_GROUP
```

---

### Step 3: Associate VPC with Endpoint Group

This association links your consumer VPC to the Intercept Endpoint Group, enabling traffic from this VPC to be intercepted and inspected.

```bash
gcloud network-security intercept-endpoint-group-associations create consumer-epg-association \
    --project=$CONSUMER_PROJECT \
    --location=global \
    --network=$CONSUMER_VPC \
    --intercept-endpoint-group=consumer-intercept-epg
```

---

### Step 4: Create Security Profile

The Security Profile defines which traffic should be inspected. This custom intercept profile references the Intercept Endpoint Group to route traffic for inspection.

```bash
gcloud network-security security-profiles custom-intercept create consumer-security-profile \
    --organization=$ORG_ID \
    --location=global \
    --intercept-endpoint-group=projects/$CONSUMER_PROJECT/locations/global/interceptEndpointGroups/consumer-intercept-epg
```

---

### Step 5: Create Security Profile Group

The Security Profile Group bundles one or more security profiles together, allowing you to apply multiple security policies as a single entity in firewall rules.

```bash
gcloud network-security security-profile-groups create consumer-security-profile-group \
    --organization=$ORG_ID \
    --location=global \
    --custom-intercept-profile=organizations/$ORG_ID/locations/global/securityProfiles/consumer-security-profile
```

---

### Step 6: Create Network Firewall Policy

The Network Firewall Policy is a global policy that will contain the rules directing traffic to the Security Profile Group for inspection.

```bash
gcloud compute network-firewall-policies create consumer-firewall-policy \
    --project=$CONSUMER_PROJECT \
    --global
```

---

### Step 7: Add Firewall Policy Rules

Create firewall rules that apply the Security Profile Group to traffic. These rules determine which traffic (ingress and/or egress) should be inspected.

**Ingress Rule:**
```bash
gcloud compute network-firewall-policies rules create 10 \
    --project=$CONSUMER_PROJECT \
    --action=apply_security_profile_group \
    --firewall-policy=consumer-firewall-policy \
    --global-firewall-policy \
    --layer4-configs=all \
    --src-ip-ranges=0.0.0.0/0 \
    --dest-ip-ranges=0.0.0.0/0 \
    --direction=INGRESS \
    --security-profile-group=organizations/$ORG_ID/locations/global/securityProfileGroups/consumer-security-profile-group
```

**Egress Rule:**
```bash
gcloud compute network-firewall-policies rules create 11 \
    --project=$CONSUMER_PROJECT \
    --action=apply_security_profile_group \
    --firewall-policy=consumer-firewall-policy \
    --global-firewall-policy \
    --layer4-configs=all \
    --src-ip-ranges=0.0.0.0/0 \
    --dest-ip-ranges=0.0.0.0/0 \
    --direction=EGRESS \
    --security-profile-group=organizations/$ORG_ID/locations/global/securityProfileGroups/consumer-security-profile-group
```

---

### Step 8: Associate Policy with VPC

Associate the Network Firewall Policy with your consumer VPC to activate traffic inspection. Once associated, all traffic matching the firewall rules will be sent to the CloudGuard gateways for inspection.

⚠️ **CAUTION:** Traffic will be intercepted and inspected after this step.

```bash
gcloud compute network-firewall-policies associations create \
    --name=consumer-policy-association \
    --global-firewall-policy \
    --firewall-policy=consumer-firewall-policy \
    --network=$CONSUMER_VPC \
    --project=$CONSUMER_PROJECT
```

---

## Connecting Multiple VPCs

A single Intercept Endpoint Group can protect multiple VPCs. 

#### Option 1: Shared Firewall Policy

To connect additional VPCs with the **same security policy**, you need to perform **two actions for each VPC**:

1. **Create endpoint association** (Step 3)
2. **Associate firewall policy** (Step 8)

All VPCs can share the same endpoint group, security profile, security profile group, and firewall policy.

**Steps for adding VPC-2:**

First, set the additional VPC name:
```bash
export CONSUMER_VPC_2="your-second-vpc-name"
```

Then run:
```bash
# 1. Associate VPC-2 with endpoint group
gcloud network-security intercept-endpoint-group-associations create vpc2-epg-association \
    --project=$CONSUMER_PROJECT \
    --location=global \
    --network=$CONSUMER_VPC_2 \
    --intercept-endpoint-group=consumer-intercept-epg

# 2. Associate firewall policy with VPC-2
gcloud compute network-firewall-policies associations create \
    --name=vpc2-policy-association \
    --global-firewall-policy \
    --firewall-policy=consumer-firewall-policy \
    --network=$CONSUMER_VPC_2 \
    --project=$CONSUMER_PROJECT
```

#### Option 2: Multiple Firewall Policies

If you need to apply **different security policies** to different VPCs, you can create multiple firewall policies and associate them with different VPCs. Each VPC can have its own firewall policy with custom rules while still using the same Intercept Endpoint Group.

To connect additional VPCs with **different security policies**, perform the following steps for each VPC:

1. **Create endpoint association** (Step 3)
2. **Create a new firewall policy** (Step 6)
3. **Add firewall policy rules** (Step 7)
4. **Associate firewall policy with VPC** (Step 8)

**Steps for adding VPC-2 with a different firewall policy:**

First, set the additional VPC name:
```bash
export CONSUMER_VPC_2="your-second-vpc-name"
```

Then run:
```bash
# 1. Associate VPC-2 with endpoint group
gcloud network-security intercept-endpoint-group-associations create vpc2-epg-association \
    --project=$CONSUMER_PROJECT \
    --location=global \
    --network=$CONSUMER_VPC_2 \
    --intercept-endpoint-group=consumer-intercept-epg

# 2. Create a new firewall policy for VPC-2
gcloud compute network-firewall-policies create vpc2-firewall-policy \
    --project=$CONSUMER_PROJECT \
    --global

# 3. Add custom rules to the VPC-2 firewall policy (Ingress)
gcloud compute network-firewall-policies rules create 10 \
    --project=$CONSUMER_PROJECT \
    --action=apply_security_profile_group \
    --firewall-policy=vpc2-firewall-policy \
    --global-firewall-policy \
    --layer4-configs=all \
    --src-ip-ranges=0.0.0.0/0 \
    --dest-ip-ranges=0.0.0.0/0 \
    --direction=INGRESS \
    --security-profile-group=organizations/$ORG_ID/locations/global/securityProfileGroups/consumer-security-profile-group

# 4. Associate the new firewall policy with VPC-2
gcloud compute network-firewall-policies associations create \
    --name=vpc2-policy-association \
    --global-firewall-policy \
    --firewall-policy=vpc2-firewall-policy \
    --network=$CONSUMER_VPC_2 \
    --project=$CONSUMER_PROJECT
```

---

## Module's variables:
| Name          | Description                                                                                                                                                                                                                                                                                                                                                           | Type          | Allowed values | Default       | Required      |
| ------------- |-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| ------------- | ------------- | ------------- | ------------- |
| project  | Personal project ID. The project indicates the default GCP project in which all your resources will be created. The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphens, and cannot end with a hyphen.                                                                                                | string  | N/A | "" | yes
| prefix | (Optional) Resources name prefix. <br/> Note: resource name must not contain reserved words based on [sk40179](https://support.checkpoint.com/results/sk/sk40179).                                                                                                                                                                                                   | string | N/A | "chkp-tf-nsi" | no |
| license | Check Point license (BYOL or PAYG). Required only if you choose to get the latest image.                                                                                                                                                                                                                                                                                                                                   | string | BYOL<br/>PAYG | "BYOL" | no |
| source_image | The NSI image name.<br/>Leave empty or set to "latest" in order to deploy with the latest image.                                                                                                | string | N/A | "" | no |
| os_version | Gaia OS Version. Required only if you choose to get the latest image.                                                                                                                                                                                                                                                                                                                                                       | string | R8120;<br/> R82; | "R82" | yes |
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
| mgmt_network_icmp_traffic | (Optional) Source IP ranges for ICMP traffic on the management VPC - Comma-separated CIDR ranges (e.g., "10.0.0.0/8, 172.16.0.0/12"). Leave empty ("") to disable ICMP traffic.                                                                                                                                                           | string | N/A | "" | no |
| mgmt_network_tcp_traffic | (Optional) Source IP ranges for TCP traffic on the management VPC - Comma-separated CIDR ranges (e.g., "10.0.0.0/8, 172.16.0.0/12"). Leave empty ("") to disable TCP traffic.                                                                                                                                                             | string | N/A | "" | no |
| mgmt_network_udp_traffic | (Optional) Source IP ranges for UDP traffic on the management VPC - Comma-separated CIDR ranges (e.g., "10.0.0.0/8, 172.16.0.0/12"). Leave empty ("") to disable UDP traffic.                                                                                                                                                             | string | N/A | "" | no |
| mgmt_network_sctp_traffic | (Optional) Source IP ranges for SCTP traffic on the management VPC - Comma-separated CIDR ranges (e.g., "10.0.0.0/8, 172.16.0.0/12"). Leave empty ("") to disable SCTP traffic.                                                                                                                                                           | string | N/A | "" | no |
| mgmt_network_esp_traffic | (Optional) Source IP ranges for ESP traffic on the management VPC - Comma-separated CIDR ranges (e.g., "10.0.0.0/8, 172.16.0.0/12"). Leave empty ("") to disable ESP traffic.                                                                                                                                                             | string | N/A | "" | no |
| machine_type | Machine Type.                                                                                                                                                                                                                                                                                                                                                         | string | N/A | "n1-standard-4" | no |
| cpu_usage | Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance.                                                                                                                                                                                                                                       | number | number between 10 and 90 | 60 | no |
| instances_min_group_size | The minimal number of instances                                                                                                                                                                                                                                                                                                                                       | number | N/A | 2 | no |
| instances_max_group_size | The maximal number of instances                                                                                                                                                                                                                                                                                                                                       | number | N/A | 10 | no |
| disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency.                                                                                                                                                                                                       | string | SSD Persistent Disk <br/> Balanced Persistent Disk <br/> Standard Persistent Disk | "SSD Persistent Disk" | no |
| disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space.                                                                                                                                                                                                     | number | number between 100 and 4096 | 100 | no |
| enable_monitoring | Enable Stackdriver monitoring                                                                                                                                                                                                                                                                                                                                         | bool | true <br/> false | false | no |
| connection_draining_timeout | The time, in seconds, that the load balancer waits for active connections to complete before fully removing an instance from the backend group.                                                                                                                                                                                                                                                     | number | N/A | 300 | no |

## Outputs

This module provides outputs for networks, firewall rules, autoscaling components, and NSI resources.

### Adding Outputs to Your Configuration

Module outputs must be defined in your `main.tf` to be accessible. Add output blocks after the module call:

**Example 1: Get all outputs in a single block**

```hcl
output "nsi_outputs" {
  value       = module.nsi_producer
  description = "All outputs from the NSI module"
}
```

**Example 2: Get specific outputs**

```hcl
output "intercept_deployment_group_id" {
  value       = module.nsi_producer.intercept_deployment_group_id
  description = "Intercept Deployment Group ID for consumer setup"
}

output "mgmt_network_name" {
  value       = module.nsi_producer.mgmt_network_name
  description = "Management VPC network name"
}
```

### Viewing Outputs

After `terraform apply`, outputs are displayed automatically. View them anytime using:

```bash
terraform output                            # View all outputs
terraform output intercept_deployment_group_id  # View specific output
terraform output -json                      # View in JSON format
```

### Available Outputs

| Category | Output Name | Description |
|----------|-------------|-------------|
| **Networks** | `mgmt_network_name` | Management VPC network name (if created) |
| | `mgmt_subnetwork_name` | Management VPC subnetwork name (if created) |
| | `security_network_name` | Security VPC network name (if created) |
| | `security_subnetwork_name` | Security VPC subnetwork name (if created) |
| | `security_network_gateway_address` | Security VPC gateway IP address |
| **Firewall Rules** | `mgmt_network_icmp_firewall_rule` | Management VPC ICMP firewall rule name |
| | `mgmt_network_tcp_firewall_rule` | Management VPC TCP firewall rule name |
| | `mgmt_network_udp_firewall_rule` | Management VPC UDP firewall rule name |
| | `mgmt_network_sctp_firewall_rule` | Management VPC SCTP firewall rule name |
| | `mgmt_network_esp_firewall_rule` | Management VPC ESP firewall rule name |
| **Check Point** | `management_name` | Security Management Server name |
| | `configuration_template_name` | Configuration template name |
| | `source_image` | CloudGuard gateway image used |
| **Autoscaling** | `instance_template_name` | Instance template name |
| | `instance_group_manager_name` | Instance group manager name |
| | `autoscaler_name` | Autoscaler name |
| **NSI Resources** | `intercept_deployment_group_id` | Intercept Deployment Group ID |
| | `forwarding_rule` | Map of forwarding rules by zone |