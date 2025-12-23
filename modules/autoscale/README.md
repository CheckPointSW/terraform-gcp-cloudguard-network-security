# Check Point Autoscale into VPC (MIG) Terraform module for GCP

Terraform module which deploys an Auto Scaling Group of Check Point Security Gateways on GCP.

These types of Terraform resources are supported:
* [Instance Template](https://www.terraform.io/docs/providers/google/r/compute_instance_template.html)
* [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation
* [Instance Group Manager](https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html)
* [Autoscaler](https://www.terraform.io/docs/providers/google/r/compute_region_autoscaler.html)

For additional information,
please see the [CloudGuard Network for GCP Autoscaling MIG Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_Autoscaling_MIG/Default.htm)

## Usage
```hcl
provider "google" {
    credentials = file("service-accounts/service-account-file-name.json")
    project     = "your-gcp-project-id"
    region      = "us-central1"
}

module "example_module" {
    source  = "CheckPointSW/cloudguard-network-security/gcp//modules/autoscale"
    version = "~> 1.0"

    # --- Project Configuration ---
    project_id = "your-gcp-project-id"
    zone = "us-central1-a"

    # --- Check Point Configuration ---
    prefix = "chkp-tf-mig"
    source_image = ""
    os_version = "R82"
    license = "BYOL"
    management_nic = "Ephemeral Public IP (eth0)"
    management_name = "tf-checkpoint-management"
    configuration_template_name = "tf-asg-autoprov-tmplt"
    generate_password = true
    admin_SSH_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    maintenance_mode_password = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    sic_key = "xxxxxxxxx"
    network_defined_by_routes = true
    admin_shell = "/etc/cli.sh"
    allow_upload_download = true

    # --- Networking ---
    external_network_name = ""
    external_subnetwork_name = ""
    external_network_cidr = "10.0.1.0/24"
    internal_network_name = ""
    internal_subnetwork_name = ""
    internal_network_cidr = "10.0.2.0/24"

    # --- Firewall Rules - IPv4 ---
    external_network_icmp_source_ranges = "123.123.0.0/24, 234.234.0.0/24"
    external_network_tcp_source_ranges = "0.0.0.0/0"
    external_network_udp_source_ranges = "0.0.0.0/0"
    external_network_sctp_source_ranges = ""
    external_network_esp_source_ranges = ""

    # --- Instance Configuration ---
    machine_type = "n1-standard-4"
    cpu_usage = 60
    instances_min_group_size = 2
    instances_max_group_size = 10
    boot_disk_type = "SSD Persistent Disk"
    boot_disk_size = 100
    enable_monitoring = false
}
```

## VPC
For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.
- If you want to create a new network and subnet, please input a subnet CIDR block for the desired new network - In this case, the network name and subnetwork name will not be used:

    ```
    external_network_name = ""                 # Leave empty when creating new network
    external_subnetwork_name = ""              # Leave empty when creating new network
    external_network_cidr = "10.0.1.0/24"
    ```

- Otherwise, if you want to use existing network and subnet, please leave empty double quotes in the CIDR variable for the desired network:

    ```
    external_network_name = "network name"
    external_subnetwork_name = "subnetwork name"
    external_network_cidr = ""
    ```

## Multi-Project (Shared VPC) Support
To attach the autoscale gateways to networks that live in a different host project (Shared VPC), set:

```
project_id = "service-project-id"        # provider context
external_network_project = "host-project-id"
internal_network_project = "host-project-id"
```

Leave the network project variable(s) empty when network(s) are in the same project.

**Note:** All networks must reside in projects within the same GCP organization. Cross-organization Shared VPC is not supported.

## Firewall Rules
To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter string of Source IP ranges seperated by comma:

```
external_network_icmp_source_ranges = ""123.123.0.0/24, 234.234.0.0/24""
external_network_tcp_source_ranges = "0.0.0.0/0"
external_network_udp_source_ranges = "0.0.0.0/0"
external_network_sctp_source_ranges = ""
external_network_esp_source_ranges = ""
```

Please leave empty `""` for a protocol if you want to disable traffic for it.

## Images
You can choose to either deploy with the latest image or with a custom image.
- If you want to deploy with the latest image leave the `source_image` empty or with `"latest"` keyword and specify the `os_version` and `license`:

    ```
    source_image = ""
    os_version = "R82"
    license = "BYOL"
    ```

- Otherwise specify the `source_image` with the path to the image:

    ```
    source_image = "check-point-r82-gw-byol-mig-777-991001866-v20250731"
    os_version = ""                            # Leave empty when using specific image
    license = ""                               # Leave empty when using specific image
    ```

If you want to deploy with a specific image you can checkout this section to get a list of images to deploy with:
1. Download and install [`gcloud cli`](https://cloud.google.com/sdk/docs/install-sdk).
2. Make sure you are logged in using `gcloud auth login`.
3. Run for:<br/>
    `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-gw-LICENSE-mig-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`

    Replace:
    - `VERSION` with either `r8110`, `r8120`, `r82`.
    - `LICENSE` with either `byol` or `payg`.
4. Choose the image name you wan't. Note that the newest one are the top of the list.

## Inputs
| Name | Description | Type | Allowed values | Default | Required |
| -----| ----------- | ---- | -------------- | ------- | ---------|
| project_id  | Personal project ID. The project indicates the default GCP project all of your resources will be created in. The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphenst and cannot end with a hyphen. | string | N/A | "" | Yes |
| zone | The zone for the solution to be deployed. | string | N/A | "us-central1-a" | No |
| prefix | The prefix to use for resource naming <br/> Note: resource name must not contain reserved words based on: sk40179.  | string | N/A | "chkp-tf-mig" | No |
| license | Checkpoint license (BYOL or PAYG). Required only if you choose to get the latest image. | string | BYOL;<br/> PAYG;<br/> | "BYOL" | No |
| source_image | The autoscaling (MIG) image name.<br/>Leave empty or set to "latest" in order to deploy with the latest image. | string | N/A | "" | No |
| os_version | GAIA OS Version. Required only if you choose to get the latest image. | string | R8110;<br/> R8120;<br/> R82; | "R82" | No |
| management_nic | Management Interface - Autoscaling Security Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1). | string | Ephemeral Public IP (eth0);<br/> Private IP (eth1); | "Ephemeral Public IP (eth0)" | No |
| management_name | The name of the Security Management Server as appears in autoprovisioning configuration. (Please enter a valid Security Management name including lowercase letters, digits and hyphens only). | string | N/A | "checkpoint-management" | No |
| configuration_template_name | Specify the provisioning configuration template name (for autoprovisioning). (Please enter a valid autoprovisioing configuration template name including lowercase letters, digits and hyphens only). | string | N/A | "gcp-asg-autoprov-tmplt" | No |
| generate_password  | Automatically generate an administrator password. | bool | true/false | false | No |
| admin_SSH_key | Public SSH key for the user 'admin' - The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys. | string | A valid public ssh key | "" | No |
| maintenance_mode_password | Maintenance mode password, relevant only for R81.20 and higher versions. | string |  N/A | "" | No |
| sic_key | The Secure Internal Communication one time secret used to set up trust between the gateway object and the management server. | string | At least 8 alpha numeric characters.<br/>If SIC is not provided and needed, a key will be automatically generated | "" | No |
| network_defined_by_routes | Set eth1 topology to define the networks behind this interface by the routes configured on the gateway. | bool | true/false | true | No |
| admin_shell | Change the admin shell to enable advanced command line configuration. | string | /etc/cli.sh;<br/> /bin/bash;<br/> /bin/csh;<br/> /bin/tcsh; | "/etc/cli.sh" | No |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | bool | true/false | true | No |
| external_network_name | The network determines what network traffic the instance can access. | string | N/A | N/A | Yes |
| external_subnetwork_name | Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | N/A | N/A | Yes |
| external_network_cidr | The range of internal addresses that are owned by this network, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16"). | string | N/A |"10.0.1.0/24" | No |
| internal_network_name | The network determines what network traffic the instance can access. | string | N/A | N/A | Yes |
| internal_subnetwork_name | Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | N/A | N/A | Yes |
| internal_network_cidr | The range of internal addresses that are owned by this network, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16"). | string | N/A |"10.0.2.0/24" | No |
| external_network_project | Project ID where the external network/subnetwork reside (shared VPC host). Empty -> same as provider project. | string | N/A | "" | No |
| internal_network_project | Project ID where the internal network/subnetwork reside (shared VPC host). Empty -> same as provider project. | string | N/A | "" | No |
| external_network_icmp_source_ranges | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to unable ICMP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_tcp_source_ranges | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to unable TCP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_udp_source_ranges | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to unable UDP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_sctp_source_ranges | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to unable SCTP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_esp_source_ranges | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to unable ESP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| machine_type | Machine Type. | string. | N/A | "n1-standard-4" | No |
| cpu_usage | Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance. | number | number between 10 and 90 | 60 | No |
| instances_min_group_size | The minimal number of instances. | number | N/A | 2 | No |
| instances_max_group_size | The maximal number of instances. | number | N/A | 10 | No |
| boot_disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency. | string | SSD Persistent Disk <br/> Balanced Persistent Disk;<br/> Standard Persistent Disk; | "SSD Persistent Disk" | No |
| boot_disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. | number | number between 100 and 4096 | 100 | No |
| enable_monitoring | Enable Stackdriver monitoring. | bool | true/false | false | No |

## Outputs

This module provides outputs for networks, firewall rules, IP addresses, and security credentials.

### Adding Outputs to Your Configuration

Module outputs must be defined in your `main.tf` to be accessible. Add output blocks **after** the module call:

**Example 1: Get all outputs in a single block**
```hcl
output "autoscale_outputs" {
  value       = module.example_module
  description = "All outputs from the autoscale module"
}
```

**Example 2: Get specific outputs**
```hcl
output "external_network" {
  value       = module.example_module.external_network_name
  description = "External network name"
}

output "admin_password" {
  value       = module.example_module.admin_password
  description = "Admin password"
  sensitive   = true  # Hide from console output
}
```

### Viewing Outputs

After `terraform apply`, outputs are displayed automatically. View them anytime using:

```bash
terraform output                    # View all outputs
terraform output external_network   # View specific output
terraform output -json              # View in JSON format (including sensitive values)
```

### Available Outputs

| Category | Output Name | Description |
|----------|-------------|-------------|
| **Networks** | `external_network_name` | External network name (if created) |
| | `external_subnetwork_name` | External subnetwork name (if created) |
| | `internal_network_name` | Internal network name (if created) |
| | `internal_subnetwork_name` | Internal subnetwork name (if created) |
| **Firewall Rules** | `icmp_firewall_rules` | ICMP firewall rule names |
| | `tcp_firewall_rules` | TCP firewall rule names |
| | `udp_firewall_rules` | UDP firewall rule names |
| | `sctp_firewall_rules` | SCTP firewall rule names |
| | `esp_firewall_rules` | ESP firewall rule names |
| **Autoscaling** | `instance_template_name` | Name of the instance template |
| | `instance_group_manager_name` | Name of the managed instance group |
| | `autoscaler_name` | Name of the autoscaler |
| **Security** | `admin_password` | Auto-generated admin password (when `generate_password = true`) |
| | `sic_key` | SIC key used for gateway configuration |
| **Configuration** | `source_image` | The image used for deployment |
| | `management_name` | Configuration template name |
