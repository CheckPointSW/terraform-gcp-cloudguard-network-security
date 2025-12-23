# Check Point CloudGuard Single Gateway and Management

Terraform module which deploys a single gateway and management of Check Point Security Gateways.

These types of Terraform resources are supported:
- [Instance Template](https://www.terraform.io/docs/providers/google/r/compute_instance_template.html)
- [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation
- [Instance Group Manager](https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html)
- [Compute instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance).

See Check Point's documentation for Single [here](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk114577).

## Usage
```hcl
provider {
    service_account_path = file("service-accounts/service-account-file-name.json")
    project              = "project-id"
    region               = "region"
}

module "example_module" {
    source  = "CheckPointSW/cloudguard-network-security/gcp//modules/single"
    version = "~> 1.0"

    # --- Project Configuration ---
    project_id                           = "your-gcp-project-id"
    
    prefix                               = "chkp-single-tf-"
    source_image                         = ""
    os_version                           = "R82"
    license                              = "BYOL"
    installation_type                    = "Gateway only"
    management_interface                 = "Ephemeral Public IP (eth0)"
    admin_shell                          = "/etc/cli.sh"
    public_ssh_key                       = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    maintenance_mode_password            = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    generate_password                    = false
    allow_upload_download                = true
    sic_key                              = "xxxxxxxxx"
    management_gui_client_network        = "0.0.0.0/0"

    # --- Quick connect to Smart-1 Cloud ---
    smart_1_cloud_token                  = "xxxxxxxxxxxxxxxxxxxxxxxx"

    # --- Networking ---
    zone                                 = "us-central1-a"
    network_name                         = ""
    subnetwork_name                      = ""
    network_cidr                         = "10.0.0.0/24"
    network_tcp_source_ranges            = "0.0.0.0/0"
    network_icmp_source_ranges           = ""
    network_udp_source_ranges            = ""
    network_sctp_source_ranges           = ""
    network_esp_source_ranges            = ""
    num_additional_networks              = 1
    external_ip                          = "static"
    internal_network1_name               = ""
    internal_network1_subnetwork_name    = ""
    internal_network1_cidr               = "10.0.1.0/24"

    # --- Instance Configuration ---
    machine_type                         = "n1-standard-4"
    boot_disk_type                       = "SSD Persistent Disk"
    boot_disk_size                       = 100
    enable_monitoring                    = false
}
```

## VPC
For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.
- If you want to create a new network and subnet, please input a subnet CIDR block for the desired new network - In this case, the network name and subnetwork name will not be used:

    ```
    network_cidr = "10.0.1.0/24"
    network_name = ""       # Leave empty when specifying a CIDR
    subnetwork_name = ""    # Leave empty when specifying a CIDR
    ```

- Otherwise, if you want to use existing network and subnet, please leave empty double quotes in the CIDR variable for the desired network:

    ```
    network_cidr = ""
    network_name = "network_name"
    subnetwork_name = "subnetwork_name"
    ```

## Multi-Project (Shared VPC) Support
To attach the management or single gateway to networks that live in a different host project (Shared VPC), set:

```
project_id = "service-project-id"        # provider context
network_project = "host-project-id"      # external network lives here
# For additional internal networks in single gateway deployments: 
internal_network1_project = "host-project-id"  # internal network lives here (when using additional networks)
```

Leave the network project variable(s) empty when network(s) are in the same project.
### Limitation
Shared VPC is not supported across organizations. The host project and service project must be in the same organization.


## Firewall Rules
To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter list of Source IP ranges.

```
ICMP_traffic = "123.123.0.0/24, 234.234.0.0/24"
TCP_traffic = "0.0.0.0/0"
UDP_traffic = "0.0.0.0/0"
SCTP_traffic = "0.0.0.0/0"
ESP_traffic = "0.0.0.0/0"
```

Please leave empty "" for a protocol if you want to disable traffic for it.

## Images
You can choose to either deploy with the latest image or with a custom image.
- If you want to deploy with the latest image leave the `source_image` empty or with `"latest"` keyword and specify the `os_version`, `license`, and `installation_type`:

  ```
  source_image = ""
  os_version = "R82"
  license = "BYOL"
  installation_type = "Gateway only"
  ```

- Otherwise specify the `source_image` with the path to the image:

  ```
  source_image = "check-point-r82-gw-byol-single-777-991001869-v20250727"
  os_version = ""     # Leave empty when specifying an image
  license = ""        # Leave empty when specifying an image
  installation = ""   # Leave empty when specifying an image
  ```

If you want to deploy with a specific image you can checkout this section to get a list of images to deploy with:
1. Download and install [`gcloud cli`](https://cloud.google.com/sdk/docs/install-sdk).
2. Make sure you are logged in using `gcloud auth login`.
3. Run for:<br/>
   - Management only:<br/>
     `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-LICENSE-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`.<br/>
   - Gateway only:<br/>
     `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-gw-LICENSE-single-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`.<br/>
   - Gateway and Management (Standalone):<br/>
     `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-LICENSE-sa-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`.<br/>
   - Manual Configuration:<br/>
     `gcloud compute images list --project "checkpoint-public" --filter="name~'^check-point-VERSION-LICENSE-mc-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*'" --format="table(name, creationTimestamp:sort=2:reverse)"`.<br/>

    Replace:
    - `VERSION` with either `r8110`, `r8120`, `r82`.
    - `LICENSE` with either `byol` or `payg`.
4. Choose the image name you want. Note that the newest one are the top of the list.

## Inputs
| Name | Description | Type | Allowed values | Default | Required |
| -----| ----------- | ---- | ---------------| ------- | -------- |
| project_id | Personal project ID. The project indicates the default GCP project all of your resources will be created in. The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphenst and cannot end with a hyphen. | string | N/A | "" | Yes |
| zone | The zone determines what computing resources are available and where your data is stored and used. | string | List of allowed [Regions and Zones](https://cloud.google.com/compute/docs/regions-zones?_ga=2.31926582.-962483654.1585043745) | us-central1-a | Yes |
| source_image | The single gateway or management image name.<br/>Leave empty or set to "latest" in order to deploy with the latest image. | string | "" | N/A | No |
| os_version | GAIA OS Version. Required only if you choose to get the latest image. | string | R8110;<br/> R8120;<br/> R82; | "R82" | No |
| installation_type | Installation type. Required only if you choose to get the latest image. | string | Gateway only;<br/> Management only;<br/> Manual Configuration;<br/>Gateway and Management (Standalone); | Gateway only | No |
| license | Checkpoint license (BYOL or PAYG). Required only if you choose to get the latest image. | string | BYOL;<br/>PAYG; | BYOL | No |
| prefix | The prefix to use for resource naming | string | N/A | chkp-single-tf | No |
| machine_type | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have. | string | [Learn more about Machine Types](https://cloud.google.com/compute/docs/machine-types?hl=en_US&_ga=2.267871494.-962483654.1585043745) | n1-standard-4 | No |
| network_name | network ID in the chosen zone. The network determines what network traffic the instance can. | string | N/A | N/A | No |
| subnetwork_name | subNetwork ID in the chosen zone. The subNetwork determines what network traffic the instance can access. | string | N/A| N/A | No |
| network_cidr | The range of internal addresses that are owned by this network, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16"). | string | N/A | "" | No |
| TCP_traffic | Allow TCP traffic from the Internet. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009 [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls)| N/A | No |
| ICMP_traffic | Source IP ranges for ICMP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) | N/A | No |
| UDP_traffic | Source IP ranges for UDP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) | N/A | No |
| SCTP_traffic | Source IP ranges for SCTP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) | N/A | No |
| ESP_traffic | Source IP ranges for ESP traffic. For multiple ranges split them by a comma e.g. "123.123.0.0/0, 234.234.0.0./0". | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) | N/A | No |
| boot_disk_type | Disk type. | string | SSD Persistent Disk;<br/>standard-Persistent Disk;<br/>Storage space is much less expensive for a standard persistent disk. An SSD persistent disk is better for random IOPS or streaming throughput with low latency. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.66020774.-962483654.1585043745#overview_of_disk_types) | SSD Persistent Disk | No |
| boot_disk_size | Disk size in GB. | number | Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.232680471.-962483654.1585043745#pdperformance) | 100 | No |
| generate_password | Automatically generate an administrator password. | boolean | true; <br/>false; | false | No |
| allow_upload_download | Allow download from/upload to Check Point. | boolean | true; <br/>false; | true | No |
| enable_monitoring | Enable Stackdriver monitoring. | boolean | true; <br/>false; | false | No |
| admin_shell | Change the admin shell to enable advanced command line configuration. | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh; | /etc/cli.sh | No |
| public_ssh_key | Public SSH key for the user 'admin' - The SSH public key for SSH authentication to the instances. Leave this field blank to use all project-wide pre-configured SSH keys. | string | A valid public ssh key. | "" | No |
| maintenance_mode_password | Maintenance mode password hash, relevant only for R81.20 and higher versions, to generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here. | string | N/A | "" | No |
| sic_key | The Secure Internal Communication one time secret used to set up trust between the single gateway object and the management server. | string | At least 8 alpha numeric characters.<br/>If SIC is not provided and needed, a key will be automatically generated | "" | No |
| smart_1_cloud_token | Smart-1 Cloud token to connect this Gateway to Check Point's Security Management as a Service. <br/><br/> Follow these instructions to quickly connect this gateway to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501) <br/><br/> Copy only the token value from the Smart-1 Cloud portal, without the command prefix (e.g., `set security-gateway cloud-mgmt-service on auth-token`). The token should be the alphanumeric string only. | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. | "" | No |
| management_gui_client_network | Allowed GUI clients. | string | A valid IPv4 network CIDR (e.g. 0.0.0.0/0). | 0.0.0.0/0 | No |
| num_additional_networks | Number of additional network interfaces. | number | A number in the range 1 - 7.<br/>Multiple network interfaces deployment is described in [sk121637 - Deploy a CloudGuard for GCP with Multiple Network Interfaces](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk121637) | 0 | No |
| external_ip | External IP address type. | string | static;<br/>ephemeral;<br/>An external IP address associated with this instance. Selecting "none" will result in the instance having no external internet access. [Learn more](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?_ga=2.259654658.-962483654.1585043745) | static | No |
| internal_network1_name | 1st internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network1_cidr, this network name will not be used.| string | Available network in the chosen zone | N/A | No |
| internal_network1_subnetwork_name | 1st internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network1_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | Available subNetwork in the chosen zone. | N/A | No |
| internal_network1_cidr | The range of internal addresses that are owned by this subnetwork, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16"). | string | N/A| N/A | No |
| management_interface | Management Interface - Security Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1). | string | Ephemeral Public IP (eth0)<br/> Private IP (eth1) | Ephemeral Public IP (eth0) | No |

## Outputs

This module provides outputs for networks, firewall rules, IP addresses, and security credentials.

### Adding Outputs to Your Configuration

Module outputs must be defined in your `main.tf` to be accessible. Add output blocks **after** the module call:

**Example 1: Get all outputs in a single block**
```hcl
output "single_outputs" {
  value       = module.example_module
  description = "All outputs from the single module"
}
```

**Example 2: Get specific outputs**
```hcl
output "external_network" {
  value       = module.example_module.network
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
| **Networks** | `network` | External network name (if created) |
| | `subnetwork` | External subnetwork name (if created) |
| | `int_network1_new_created_network` | 1st internal network name |
| | `int_network1_new_created_subnet` | 1st internal subnetwork name |
| | `int_network2_new_created_network` through `int_network7_new_created_network` | 2nd-7th internal network names |
| | `int_network2_new_created_subnet` through `int_network7_new_created_subnet` | 2nd-7th internal subnetwork names |
| **Firewall Rules** | `network_icmp_firewall_rules` | ICMP firewall rule names |
| | `network_tcp_firewall_rules` | TCP firewall rule names |
| | `network_udp_firewall_rules` | UDP firewall rule names |
| | `network_sctp_firewall_rules` | SCTP firewall rule names |
| | `network_esp_firewall_rules` | ESP firewall rule names |
| **IP Addresses** | `external_ip` | External IPv4 address of the gateway |
| **Security** | `admin_password` | Auto-generated admin password (when `generate_password = true`) |
| | `sic_key` | SIC key used for gateway configuration |
| **Configuration** | `source_image` | The image used for deployment |

**Note:** Internal network outputs are available based on the `num_additional_networks` variable (0-7). For example, if `num_additional_networks = 2`, you can access `int_network1_*` and `int_network2_*` outputs.