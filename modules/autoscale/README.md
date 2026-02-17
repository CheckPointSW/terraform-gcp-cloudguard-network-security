# Check Point Autoscale into VPC (MIG) Terraform module for GCP

Terraform module which deploys an Auto Scaling Group of Check Point Security Gateways on GCP with support for IPv4-only or IPv4/IPv6 dual-stack.

These types of Terraform resources are supported:
* [Instance Template](https://www.terraform.io/docs/providers/google/r/compute_instance_template.html)
* [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation
* [Instance Group Manager](https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html)
* [Autoscaler](https://www.terraform.io/docs/providers/google/r/compute_region_autoscaler.html)
* [External Network Load Balancer](https://www.terraform.io/docs/providers/google/r/compute_forwarding_rule.html) - conditional creation
* [Internal Network Load Balancer](https://www.terraform.io/docs/providers/google/r/compute_forwarding_rule.html) - conditional creation

For additional information,
please see the [CloudGuard Network for GCP Autoscaling MIG Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_Autoscaling_MIG/Default.htm)

## Usage

### Example Deployments

<details>
<summary><b>IPv4 Only Deployment Example</b></summary>
<br>

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
</details>

<details>
<summary><b>IPv6 Dual-Stack Deployment Example</b></summary>
<br>

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
    prefix = "chkp-tf-mig-ipv6"
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
    
    # --- IPv6 Dual-Stack Configuration ---
    ip_stack_type = "IPV4_IPV6"
    external_network_ipv6_ula = ""  # Auto-generated
    internal_network_ipv6_ula = ""  # Auto-generated
    
    # --- Firewall Rules - IPv4 ---
    external_network_icmp_source_ranges = "123.123.0.0/24, 234.234.0.0/24"
    external_network_tcp_source_ranges = "0.0.0.0/0"
    external_network_udp_source_ranges = "0.0.0.0/0"
    external_network_sctp_source_ranges = ""
    external_network_esp_source_ranges = ""
    
    # --- Firewall Rules - IPv6 ---
    external_network_icmp_ipv6_source_ranges = "::/0"
    external_network_tcp_ipv6_source_ranges = "::/0"
    external_network_udp_ipv6_source_ranges = "::/0"
    external_network_sctp_ipv6_source_ranges = ""
    external_network_esp_ipv6_source_ranges = ""

    # --- Instance Configuration ---
    machine_type = "n1-standard-4"
    cpu_usage = 60
    instances_min_group_size = 1
    instances_max_group_size = 3
    boot_disk_type = "SSD Persistent Disk"
    boot_disk_size = 100
    enable_monitoring = false
}
```
</details>

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

## Load Balancers

This module automatically deploys both **External** and **Internal** Network Load Balancers (deployed by default) to distribute traffic to your Check Point Security Gateways.

### Configuration Overview

**External Load Balancer:**
- **Type**: Network Load Balancing
- **Load balancer type**: Passthrough load balancer
- **Backend type**: Backend service
- **Protocol**: TCP
- **IP address**: Static external IP (automatically created)
- **Port**: All
- **Session affinity**: Client IP and protocol
- **Health check**: TCP on port 8117
- **Backend**: Managed Instance Group (regional)

**Internal Load Balancer:**
- **Type**: Network Load Balancing
- **Load balancer type**: Passthrough load balancer
- **Backend type**: Backend service
- **Protocol**: TCP
- **IP address**: Static internal IP (automatically created)
- **Port**: All
- **Session affinity**: None
- **Health check**: TCP on port 8117
- **Backend**: Managed Instance Group (regional)
- **Network**: Internal network (eth1)
- **Subnetwork**: Internal subnetwork

### Disabling Load Balancers

To disable deployment of one or both load balancers, add to your module configuration:

```hcl
module "example_module" {
  source = "CheckPointSW/cloudguard-network-security/gcp//modules/autoscale"
  
  # ... other configuration ...
  
  deploy_external_lb = false
  deploy_internal_lb = false
}
```

**Note for Shared VPC Deployments:**

Load balancers are deployed in the service project (`project_id`). If you disable automatic deployment, manually create the load balancers in the service project.

**Note for IPv6 Dual-Stack Deployments:**

When deploying with `ip_stack_type = "IPV4_IPV6"`, load balancers are deployed with HTTPS port 443 health checks (instead of TCP port 8117) for both external and internal load balancers.

## IPv6 Dual-Stack Support

This module supports IPv6 dual-stack networking alongside IPv4.

**Important:** Additional configuration is required for health probes to work correctly. For detailed configuration steps, see the [Admin Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_Autoscaling_MIG/Content/Topics-GCP-Autoscaling-MIG/Configuration.htm?Highlight=L3%20protocols#Step_5__Configure_Load_Balancers).

### IPv6 Access Types

- **External Network (eth0):** 
  - **Default behavior**: Gets global IPv6 addresses (EXTERNAL access type) for public internet connectivity
  - **Private IPv6**: Uses ULA IPv6 addresses (INTERNAL access type) only when `management_nic = "Private IP (eth1)"`
  
- **Internal Network (eth1):** 
  - Always uses ULA IPv6 addresses (INTERNAL access type) for private communication

**Key Points:**
- IPv6 addresses are deployed on the same NICs as IPv4 in dual-stack mode
- Each network interface can only have **one** IPv6 access type - either EXTERNAL or INTERNAL, not both
- The `management_nic` setting controls both IPv4 and IPv6 access for the external interface

### IPv6 Configuration

#### Enabling Dual-Stack
Set `ip_stack_type = "IPV4_IPV6"` to enable dual-stack support

#### IPv6 ULA Ranges (Optional)

```hcl
external_network_ipv6_ula = ""  # Only used with private IPv6. Leave empty (recommended)
internal_network_ipv6_ula = ""  # Leave empty for GCP auto-generation (recommended)
```

**Notes:**
- **Recommended**: Leave both ULA fields empty - GCP will auto-generate valid ranges when needed
- **External ULA**: Only applicable when using private IPv6 (`management_nic = "Private IP (eth1)"`). With default public IPv6, external network gets global addresses (not ULA)
- **Note**: When deploying a new VPC and specifying a ULA field, the corresponding CIDR field is mandatory (e.g., if specifying `external_network_ipv6_ula`, then `external_network_cidr` is required; if specifying `internal_network_ipv6_ula`, then `internal_network_cidr` is required)

#### IPv6 Firewall Rules (Optional)

```hcl
external_network_icmp_ipv6_source_ranges = "::/0"         # Allow IPv6 ICMP from anywhere
external_network_tcp_ipv6_source_ranges = "::/0"          # Allow IPv6 TCP from anywhere
external_network_udp_ipv6_source_ranges = "::/0"          # Allow IPv6 UDP from anywhere
external_network_sctp_ipv6_source_ranges = ""             # Disable IPv6 SCTP
external_network_esp_ipv6_source_ranges = ""              # Disable IPv6 ESP
```

### IPv6 ULA Technical Requirements

When manually specifying ULA ranges:
- Must use `fd20::/20` prefix range (fd20:0000:0000::/48 to fd20:0fff:ffff::/48)
- Must be `/48` network size
- Examples: `fd20:0123:4567::/48`, `fd20:0abc:def0::/48`, `fd20:0999:1234::/48`
- **Important**: Once a ULA range has been used, it cannot be reused (even if the network has been deleted)
- **Best Practice**: Leave empty and let GCP handle ULA generation automatically

## Firewall Rules
To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter string of Source IP ranges separated by comma:

**IPv4 Firewall Rules:**
```
external_network_icmp_source_ranges = "123.123.0.0/24, 234.234.0.0/24"
external_network_tcp_source_ranges = "0.0.0.0/0"
external_network_udp_source_ranges = "0.0.0.0/0"
external_network_sctp_source_ranges = ""
external_network_esp_source_ranges = ""
```

**IPv6 Firewall Rules (when ip_stack_type = "IPV4_IPV6"):**
```
external_network_icmp_ipv6_source_ranges = "2001:db8::/32, 2001:db9::/32"
external_network_tcp_ipv6_source_ranges = "::/0"
external_network_udp_ipv6_source_ranges = ""
external_network_sctp_ipv6_source_ranges = ""
external_network_esp_ipv6_source_ranges = ""
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
| os_version | GAIA OS Version. Required only if you choose to get the latest image. | string | R8110;<br/> R8120;<br/> R82;<br/> R8210; | "R82" | No |
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
| external_network_icmp_source_ranges | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to disable ICMP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_tcp_source_ranges | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to disable TCP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_udp_source_ranges | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to disable UDP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_sctp_source_ranges | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to disable SCTP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| external_network_esp_source_ranges | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty string to disable ESP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| ip_stack_type | The IP stack type for network interfaces. Set to IPV4_IPV6 for dual-stack support. | string | IPV4_ONLY;<br/>IPV4_IPV6; | "IPV4_ONLY" | No |
| external_network_ipv6_ula | The IPv6 ULA range for the external network. Only applicable when using private IPv6 (management_nic = "Private IP (eth1)"). When using default public IPv6, the external network gets global IPv6 addresses and this field is not used. Recommended to keep empty - GCP will auto-generate ULA when needed and ip_stack_type is IPV4_IPV6. If specified, must be a valid /48 ULA range within fd20::/20 (fd20:0000:0000::/48 to fd20:0fff:ffff::/48). Note: When deploying a new VPC with this field specified, external_network_cidr is required. | string | fd20:0xxx:xxxx::/48 | "" | No |
| internal_network_ipv6_ula | The IPv6 ULA range for the internal network. Internal networks always use ULA IPv6 addresses for private communication. Recommended to keep empty - GCP will auto-generate valid ULA when ip_stack_type is IPV4_IPV6. If specified, must be a valid /48 ULA range within fd20::/20 (fd20:0000:0000::/48 to fd20:0fff:ffff::/48). Note: When deploying a new VPC with this field specified, internal_network_cidr is required. | string | fd20:0xxx:xxxx::/48 | "" | No |
| external_network_icmp_ipv6_source_ranges | (Optional) Source IPv6 ranges for ICMP traffic - IPv6 traffic is only allowed from sources within these IP address ranges. Use IPv6 CIDR notation when entering ranges. Please leave empty string to disable IPv6 ICMP traffic. For multiple ranges split them by a comma e.g. "2001:db8::/32, ::/0". | string | N/A | "" | No |
| external_network_tcp_ipv6_source_ranges | (Optional) Source IPv6 ranges for TCP traffic - IPv6 traffic is only allowed from sources within these IP address ranges. Use IPv6 CIDR notation when entering ranges. Please leave empty string to disable IPv6 TCP traffic. For multiple ranges split them by a comma e.g. "2001:db8::/32, ::/0". | string | N/A | "" | No |
| external_network_udp_ipv6_source_ranges | (Optional) Source IPv6 ranges for UDP traffic - IPv6 traffic is only allowed from sources within these IP address ranges. Use IPv6 CIDR notation when entering ranges. Please leave empty string to disable IPv6 UDP traffic. For multiple ranges split them by a comma e.g. "2001:db8::/32, ::/0". | string | N/A | "" | No |
| external_network_sctp_ipv6_source_ranges | (Optional) Source IPv6 ranges for SCTP traffic - IPv6 traffic is only allowed from sources within these IP address ranges. Use IPv6 CIDR notation when entering ranges. Please leave empty string to disable IPv6 SCTP traffic. For multiple ranges split them by a comma e.g. "2001:db8::/32, ::/0". | string | N/A | "" | No |
| external_network_esp_ipv6_source_ranges | (Optional) Source IPv6 ranges for ESP traffic - IPv6 traffic is only allowed from sources within these IP address ranges. Use IPv6 CIDR notation when entering ranges. Please leave empty string to disable IPv6 ESP traffic. For multiple ranges split them by a comma e.g. "2001:db8::/32, ::/0". | string | N/A | "" | No |
| machine_type | Machine Type. | string. | N/A | "n1-standard-4" | No |
| cpu_usage | Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance. | number | number between 10 and 90 | 60 | No |
| instances_min_group_size | The minimal number of instances. | number | N/A | 2 | No |
| instances_max_group_size | The maximal number of instances. | number | N/A | 10 | No |
| boot_disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency. | string | SSD Persistent Disk <br/> Balanced Persistent Disk;<br/> Standard Persistent Disk; | "SSD Persistent Disk" | No |
| boot_disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. | number | number between 100 and 4096 | 100 | No |
| enable_monitoring | Enable Stackdriver monitoring. | bool | true/false | false | No |
| deploy_external_lb | Deploy external Network Load Balancer for the MIG. The external LB distributes internet traffic to the Security Gateways. | bool | true/false | true | No |
| deploy_internal_lb | Deploy internal Network Load Balancer for the MIG. The internal LB acts as a next hop for routing traffic through the Security Gateways. | bool | true/false | true | No |

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
| **Firewall Rules - IPv4** | `icmp_firewall_rules` | ICMP firewall rule names |
| | `tcp_firewall_rules` | TCP firewall rule names |
| | `udp_firewall_rules` | UDP firewall rule names |
| | `sctp_firewall_rules` | SCTP firewall rule names |
| | `esp_firewall_rules` | ESP firewall rule names |
| **Firewall Rules - IPv6** | `icmp_ipv6_firewall_rules` | IPv6 ICMP firewall rule names (dual-stack only) |
| | `tcp_ipv6_firewall_rules` | IPv6 TCP firewall rule names (dual-stack only) |
| | `udp_ipv6_firewall_rules` | IPv6 UDP firewall rule names (dual-stack only) |
| | `sctp_ipv6_firewall_rules` | IPv6 SCTP firewall rule names (dual-stack only) |
| | `esp_ipv6_firewall_rules` | IPv6 ESP firewall rule names (dual-stack only) |
| **Autoscaling** | `instance_template_name` | Name of the instance template |
| | `instance_group_manager_name` | Name of the managed instance group |
| | `autoscaler_name` | Name of the autoscaler |
| **Security** | `admin_password` | Auto-generated admin password (when `generate_password = true`) |
| | `sic_key` | SIC key used for gateway configuration |
| **Configuration** | `source_image` | The image used for deployment |
| | `management_name` | Configuration template name |
| | `ip_stack_type` | The IP stack type used (IPV4_ONLY or IPV4_IPV6) |
| **IPv6 Networks** | `external_network_ipv6_ula` | IPv6 ULA CIDR range for external network if explicitly specified (returns empty if auto-generated by GCP) |
| | `internal_network_ipv6_ula` | IPv6 ULA CIDR range for internal network if explicitly specified (returns empty if auto-generated by GCP) |
| **Load Balancers - IPv4** | `external_lb_ip` | External load balancer static IPv4 address |
| | `internal_lb_ip` | Internal load balancer static IPv4 address |
| **Load Balancers - IPv6** | `external_lb_ipv6` | External load balancer auto-allocated IPv6 address (dual-stack only) |
| | `internal_lb_ipv6` | Internal load balancer static IPv6 address (dual-stack only) |