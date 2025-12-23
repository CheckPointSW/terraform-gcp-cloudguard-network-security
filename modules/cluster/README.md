# Check Point Cluster High Availability (HA) Terraform module for GCP

Terraform module which deploys Check Point CloudGuard IaaS High Availability solution on GCP.

These types of Terraform resources are supported:
* [Network](https://www.terraform.io/docs/providers/google/d/compute_network.html) - conditional creation
* [Subnetwork](https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html) - conditional creation
* [Instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
* [IP address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address)
* [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation

For additional information,
please see the [CloudGuard Network for GCP High Availability Cluster Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_GCP_HA_Cluster/Default.htm)

## Usage
```hcl
provider "google" {
    service_account_path = file("service-accounts/service-account-file-name.json")
    project              = "project-id"
    region               = "region"
}

module "example_module" {
    source  = "CheckPointSW/cloudguard-network-security/gcp//modules/cluster"
    version = "~> 1.0"

    project_id = "my-project-id"
    prefix = "chkp-tf-ha"
    source_image = ""
    os_version = "R82"
    license = "BYOL"

    # --- Instances Configuration ---
    zone_a = "us-central1-a"
    zone_b = "us-central1-a"
    machine_type = "n1-standard-4"
    boot_disk_type = "SSD Persistent Disk"
    boot_disk_size = 100
    public_ssh_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    enable_monitoring = false

    # --- Check Point ---
    management_network = "209.87.209.100/32"
    sic_key = "xxxxxxxxx"
    generate_password = false
    allow_upload_download = false
    admin_shell = "/bin/bash"
    maintenance_mode_password = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    # --- Quick connect to Smart-1 Cloud ---
    smart_1_cloud_token_a = "xxxxxxxxxxxxxxxxxxxxxxxx"
    smart_1_cloud_token_b = "xxxxxxxxxxxxxxxxxxxxxxxx"

    # --- Networking ---
    cluster_network_cidr = "10.0.1.0/24"
    cluster_network_name = ""
    cluster_network_subnetwork_name = ""
    cluster_network_icmp_source_ranges = "0.0.0.0/0"
    cluster_network_tcp_source_ranges = "0.0.0.0/0"
    cluster_network_udp_source_ranges = ""
    cluster_network_sctp_source_ranges = ""
    cluster_network_esp_source_ranges = ""
    mgmt_network_cidr = ""
    mgmt_network_name = "mgmt-network"
    mgmt_network_subnetwork_name = "mgmt-subnetwork"
    mgmt_network_icmp_source_ranges = ""
    mgmt_network_tcp_source_ranges = ""
    mgmt_network_udp_source_ranges = ""
    mgmt_network_sctp_source_ranges = "0.0.0.0/0"
    mgmt_network_esp_source_ranges = "0.0.0.0/0"
    num_internal_networks = 1
    internal_network1_cidr = "10.0.3.0/24"
    internal_network1_name = ""
    internal_network1_subnetwork_name = ""

    # Define internal NICs networks and subnetworks according the defined num_internal_networks value
}
``` 

## VPC
For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.
- If you want to create a new network and subnet, please input a subnet CIDR block for the desired new network - In this case, the network name and subnetwork name will not be used:

    ```
    cluster_network_cidr = "10.0.1.0/24"
    cluster_network_name = ""  # Leave empty when creating new network
    cluster_network_subnetwork_name = ""  # Leave empty when creating new network
    ```

- Otherwise, if you want to use existing network and subnet, please leave empty double quotes in the CIDR variable for the desired network:

    ```
    cluster_network_cidr = ""
    cluster_network_name = "cluster-network"
    cluster_network_subnetwork_name = "cluster-subnetwork"
    ```
## Firewall Rules
To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter list of Source IP ranges.
- For cluster:

    ```
    cluster_network_icmp_source_ranges = "123.123.0.0/24, 234.234.0.0/24"
    cluster_network_tcp_source_ranges = "0.0.0.0/0"
    cluster_network_udp_source_ranges = ""
    cluster_network_sctp_source_ranges = ""
    cluster_network_esp_source_ranges = ""
    ```

- For management:

    ```
    mgmt_network_icmp_source_ranges = "123.123.0.0/24, 234.234.0.0/24"
    mgmt_network_tcp_source_ranges = "0.0.0.0/0"
    mgmt_network_udp_source_ranges = ""
    mgmt_network_sctp_source_ranges = ""
    mgmt_network_esp_source_ranges = ""
    ```

Please leave empty "" for a protocol if you want to disable traffic for it.

## Internal Networks
The cluster members will each have a network interface in each internal network and create high priority routes that will route all outgoing traffic to the cluster member that is currently active.
<br>Using internal networks depends on the variable num_internal_networks, by selecting a number in range 1 - 6 that represents the number of internal networks:

```
num_internal_networks = 3
internal_network1_cidr = ""
internal_network1_name = "internal_network1"
internal_network1_subnetwork_name = "internal_subnetwork1"
internal_network2_cidr = "10.0.4.0/24"
internal_network2_name = ""
internal_network2_subnetwork_name = ""
internal_network3_cidr = "10.0.5.0/24"
internal_network3_name = ""
internal_network3_subnetwork_name = ""
```

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
    source_image = "check-point-r82-gw-byol-cluster-777-991001869-v20250727"
    os_version = ""  # Leave empty when specifying an image
    license = ""     # Leave empty when specifying an image
    ```

If you want to deploy with a specific image you can checkout this section to get a list of images to deploy with:
1. Download and install [`gcloud cli`](https://cloud.google.com/sdk/docs/install-sdk).
2. Make sure you are logged in using `gcloud auth login`.
3. Run for:<br/>
    `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-gw-LICENSE-cluster-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`

    Replace:
    - `VERSION` with either `r8110`, `r8120`, `r82`.
    - `LICENSE` with either `byol` or `payg`.
4. Choose the image name you wan't. Note that the newest one are the top of the list.

## Inputs
| Name | Description | Type | Allowed values | Default | Required |
| ---- | ----------- | ---- | -------------- | ------- | -------- |
| project_id | Personal project ID. The project indicates the default GCP project all of your resources will be created in. The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphenst and cannot end with a hyphen.  | string  | N/A | N/A | Yes |
| prefix | The prefix to use for resource naming | string | N/A | "chkp-tf-ha" | No |
| license | Checkpoint license (BYOL or PAYG). Required only if you choose to get the latest image. | string | BYOL;<br/> PAYG;<br/> | "BYOL" | No |
| source_image | The High Availability (cluster) image name.<br/>Leave empty or set to "latest" in order to deploy with the latest image. | string | N/A | "" | No |
| os_version | GAIA OS Version. Required only if you choose to get the latest image. | string | R8110;<br/> R8120;<br/> R82; | "R82" | No |
| zone_a | Member A Zone. The zone determines what computing resources are available and where your data is stored and used.  | string  | N/A | "us-central1-a" | No |
| zone_b | Member B Zone.  | string  | N/A | "us-central1-a" | No |
| machine_type | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have. | string | N/A | "n1-standard-4" | No |
| boot_disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency. | string | SSD Persistent Disk;<br/> Standard Persistent Disk; | "SSD Persistent Disk" | No |
| boot_disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. | number | number between 100 and 4096 | 100 | No |
| enable_monitoring | Enable Stackdriver monitoring | bool | true/false | false | No |
| management_network  | Security Management Server address - The public address of the Security Management Server, in CIDR notation. If using Smart-1 Cloud management, insert 'S1C'. VPN peers addresses cannot be in this CIDR block, so this value cannot be the zero-address. | string | N/A | N/A | Yes |
| sic_key  | The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server. At least 8 alpha numeric characters. If SIC is not provided and needed, a key will be automatically generated | string | N/A | N/A | Yes |
| generate_password  | Automatically generate an administrator password. | bool | true/false | false | No |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | bool | true/false | true | No |
| admin_shell | Change the admin shell to enable advanced command line configuration. | string | /etc/cli.sh;<br/> /bin/bash;<br/> /bin/csh;<br/> /bin/tcsh/ | "/etc/cli.sh" | No |
| maintenance_mode_password | Maintenance mode password hash, relevant only for R81.20 and higher versions, to generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here. | string | N/A | "" | No |
| smart_1_cloud_token_a | Smart-1 Cloud token to connect ***member A*** to Check Point's Security Management as a Service. <br/><br/> Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501) <br/><br/>  Copy only the token value from the Smart-1 Cloud portal, without the command prefix (e.g., `set security-gateway cloud-mgmt-service on auth-token`). The token should be the alphanumeric string only. | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. | No |
| smart_1_cloud_token_b | Smart-1 Cloud token to connect ***member B*** to Check Point's Security Management as a Service. <br/><br/> Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501) <br/><br/>  Copy only the token value from the Smart-1 Cloud portal, without the command prefix (e.g., `set security-gateway cloud-mgmt-service on auth-token`). The token should be the alphanumeric string only. | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. | No |
| cluster_network_cidr  | Cluster external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The Cluster public IP will be translated to a private address assigned to the active member in this external network. | string | N/A | "10.0.0.0/24" | No |
| cluster_network_name  | Cluster external network ID in the chosen zone. The network determines what network traffic the instance can access.If you have specified a CIDR block at var.cluster_network_cidr, this network name will not be used.  | string | N/A | "" | No |
| cluster_network_subnetwork_name  | Cluster subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.cluster_network_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | N/A | "" | No |
| cluster_network_icmp_source_ranges | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty string to unable ICMP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| cluster_network_tcp_source_ranges | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty string to unable TCP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| cluster_network_udp_source_ranges | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty string to unable UDP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| cluster_network_sctp_source_ranges | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty string to unable SCTP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| cluster_network_esp_source_ranges | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty string to unable ESP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| mgmt_network_cidr  | Management external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The public IP used to manage each member will be translated to a private address in this external network. | string | N/A | "10.0.1.0/24" | No |
| mgmt_network_name  | Management network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.mgmt_network_cidr, this network name will not be used. | string | N/A | "" | No |
| mgmt_network_subnetwork_name  | Management subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.mgmt_network_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | N/A | "" | No |
| mgmt_network_icmp_source_ranges | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty string to unable ICMP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| mgmt_network_tcp_source_ranges | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty string to unable TCP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| mgmt_network_udp_source_ranges | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty string to unable SCTP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| mgmt_network_sctp_source_ranges | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty string to unable TCP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| mgmt_network_esp_source_ranges | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty string to unable ESP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | N/A | "" | No |
| num_internal_networks | A number in the range 1 - 6 of internal network interfaces. | number | 1 - 6 | 1 | No |
| internal_network1_cidr  | 1st internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network. | string | N/A | "10.0.2.0/24" | No |
| internal_network1_name  | 1st internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network1_cidr, this network name will not be used. | string | N/A | "" | No |
| internal_network1_subnetwork_name  | 1st internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network1_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | N/A | "" | No |
| public_ssh_key | The SSH public key for SSH authentication to the cluster members. Leave this field blank to use all project-wide pre-configured SSH keys. | string | N/A | "" | No |
| deploy_with_public_ips | Deploy HA with public IPs | bool | true/false | true | No |

## Outputs

This module provides outputs for networks, firewall rules, IP addresses, and security credentials.

### Adding Outputs to Your Configuration

Module outputs must be defined in your `main.tf` to be accessible. Add output blocks **after** the module call:

**Example 1: Get all outputs in a single block**
```hcl
output "cluster_outputs" {
  value       = module.example_module
  description = "All outputs from the cluster module"
}
```

**Example 2: Get specific outputs**
```hcl
output "cluster_vip" {
  value       = module.example_module.cluster_ip_external_address
  description = "Cluster VIP - The floating external IP"
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
terraform output cluster_vip        # View specific output
terraform output -json              # View in JSON format (including sensitive values)
```

### Available Outputs

| Category | Output Name | Description |
|----------|-------------|-------------|
| **Networks** | `cluster_new_created_network` | Cluster network name (if created) |
| | `cluster_new_created_subnet` | Cluster subnetwork name (if created) |
| | `mgmt_new_created_network` | Management network name (if created) |
| | `mgmt_new_created_subnet` | Management subnetwork name (if created) |
| | `int_network1_new_created_network` | 1st internal network name |
| | `int_network1_new_created_subnet` | 1st internal subnetwork name |
| | `int_network2_new_created_network` through `int_network6_new_created_network` | 2nd-6th internal network names |
| | `int_network2_new_created_subnet` through `int_network6_new_created_subnet` | 2nd-6th internal subnetwork names |
| **Firewall Rules (Cluster)** | `cluster_icmp_firewall_rules` | Cluster ICMP firewall rule names |
| | `cluster_tcp_firewall_rules` | Cluster TCP firewall rule names |
| | `cluster_udp_firewall_rules` | Cluster UDP firewall rule names |
| | `cluster_sctp_firewall_rules` | Cluster SCTP firewall rule names |
| | `cluster_esp_firewall_rules` | Cluster ESP firewall rule names |
| **Firewall Rules (Management)** | `mgmt_icmp_firewall_rules` | Management ICMP firewall rule names |
| | `mgmt_tcp_firewall_rules` | Management TCP firewall rule names |
| | `mgmt_udp_firewall_rules` | Management UDP firewall rule names |
| | `mgmt_sctp_firewall_rules` | Management SCTP firewall rule names |
| | `mgmt_esp_firewall_rules` | Management ESP firewall rule names |
| **Cluster IPs** | `cluster_ip_external_address` | Cluster VIP (floating external IP) |
| | `member_a_external_ip` | Member A external IP address |
| | `member_b_external_ip` | Member B external IP address |
| **Cluster Members** | `member_a_name` | Member A instance name |
| | `member_a_zone` | Member A zone |
| | `member_b_name` | Member B instance name |
| | `member_b_zone` | Member B zone |
| **Security** | `admin_password` | Auto-generated admin password (when `generate_password = true`) |
| | `sic_key` | SIC key used for gateway configuration |
| **Configuration** | `source_image` | The image used for deployment |

**Note:** Internal network outputs (int_network2 through int_network6) are available based on the `num_internal_networks` variable (0-6).