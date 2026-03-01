variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

// Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  description = "The name of the deployment and VM instance."
  type        = string
  default     = "chkp-tf-ha"
}

variable "prefix" {
  type        = string
  description = "The prefix to use for resource naming. Used when deploying via Terraform (not Marketplace)."
  default     = "chkp-tf-ha"
}

variable "source_image" {
  description = "The image name for the disk for the VM instance."
  type        = string
  default     = "projects/checkpoint-public/global/images/check-point-r82-gw-byol-cluster-777-991002015-v20260215"
}

variable "os_version" {
  type        = string
  description = "The OS version of the image to use for the VM instance."
  default     = "R82"
}

variable "license" {
  type        = string
  description = "The license type for the Check Point image. Allowed values are: BYOL, PAYG."
  default     = "PAYG"
}

variable "zone_a" {
  description = "Member A Zone. The zone determines what computing resources are available and where your data is stored and used."
  type        = string
  default     = "us-central1-a"
}

variable "zone_b" {
  description = "Member B Zone. The zone determines what computing resources are available and where your data is stored and used."
  type        = string
  default     = "us-central1-a"
}

variable "deploy_with_public_ips" {
  description = "Deploy HA with public IPs"
  type        = bool
  default     = true
}

variable "machine_type" {
  description = "The machine type to create, e.g. e2-small"
  type        = string
  default     = "n1-standard-4"
}

variable "boot_disk_type" {
  description = "The boot disk type for the VM instance."
  type        = string
  default     = "SSD Persistent Disk"
}

variable "boot_disk_size" {
  description = "The boot disk size for the VM instance in GBs"
  type        = number
  default     = 100
}

variable "public_ssh_key" {
  description = "This key will be used to connect to every gateway instance created by the managed instance group. This key will replace all project-wide SSH keys"
  type        = string
  default     = ""
}

variable "admin_shell" {
  description = "Change the admin shell to enable advanced command line configuration."
  type        = string
  default     = "/etc/cli.sh"
}

variable "allow_upload_download" {
  description = "Approve to automatically download product updates and to share statistical data with Check Point for product improvement purpose. For more information see sk111080"
  type        = bool
  default     = true
}

variable "generate_password" {
  description = "To manage the environment's security, administrators can connect to the Management Server with SmartConsole clients and via the Gaia WebUI using this password"
  type        = bool
  default     = false
}

variable "maintenance_mode_password" {
  description = "Check Point recommends setting serial console password and maintenance-mode password for recovery purposes"
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  type        = bool
  default     = false
}

variable "sic_key" {
  type        = string
  description = "The Secure Internal Communication one time secret used to set up trust between the gateway object and the management server"
  default     = ""
}

variable "smart_1_cloud_token_a" {
  type        = string
  description = "(Optional) Smart-1 cloud token for member A to connect this Gateway to Check Point's Security Management as a Service"
  default     = ""
}

variable "smart_1_cloud_token_b" {
  type        = string
  description = "(Optional) Smart-1 cloud token for member B to connect this Gateway to Check Point's Security Management as a Service"
  default      = ""
}

resource "null_resource" "validate_both_tokens" {
  count = (var.smart_1_cloud_token_a != "" && var.smart_1_cloud_token_b != "") || (var.smart_1_cloud_token_a == "" && var.smart_1_cloud_token_b == "") ? 0 : "To connect to Smart-1 Cloud, you must provide two tokens (one per member)"
}

resource "null_resource" "validate_different_tokens" {
  count = var.smart_1_cloud_token_a != "" && var.smart_1_cloud_token_a == var.smart_1_cloud_token_b ? "To connect to Smart-1 Cloud, you must provide two different tokens" : 0
}

variable "management_network" {
  type        = string
  description = "Security Management Server address - The public address of the Security Management Server, in CIDR notation. If using Smart-1 Cloud management, insert 'S1C'. VPN peers addresses cannot be in this CIDR block, so this value cannot be the zero-address."
  default = "20.20.20.20/32"
}

resource "null_resource" "validate_mgmt_network_if_required" {
  count = var.smart_1_cloud_token_a == "" && var.management_network == "S1C" ? "Public address of the Security Management Server is required" : 0
}

variable "cluster_network_cidr" {
  type        = string
  description = "Cluster external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The Cluster public IP will be translated to a private address assigned to the active member in this external network."
  default     = "10.0.0.0/24"
}

variable "cluster_network_name" {
  type = string
  description = "Cluster external network ID in the chosen zone. The network determines what network traffic the instance can access."
  default = ""
}

variable "cluster_network_subnetwork_name" {
  type        = string
  description = "Cluster subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default      = ""
}

variable "cluster_network_enable_icmp" {
  type        = bool
  description = "Enable ICMP traffic"
  default     = false
}

variable "cluster_network_icmp_source_ranges" {
  type        = string
  description = "Source IP ranges for ICMP traffic"
  default     = ""
}

variable "cluster_network_enable_tcp" {
  type        = bool
  description = "Enable TCP traffic"
  default     = false
}

variable "cluster_network_tcp_source_ranges" {
  type        = string
  description = "Source IP ranges for TCP traffic"
  default     = ""
}

variable "cluster_network_enable_udp" {
  type        = bool
  description = "Enable UDP traffic"
  default     = false
}

variable "cluster_network_udp_source_ranges" {
  type        = string
  description = "Source IP ranges for UDP traffic"
  default     = ""
}

variable "cluster_network_enable_sctp" {
  type        = bool
  description = "Enable SCTP traffic"
  default     = false
}

variable "cluster_network_sctp_source_ranges" {
  type        = string
  description = "Source IP ranges for SCTP traffic"
  default     = ""
}

variable "cluster_network_enable_esp" {
  type        = bool
  description = "Enable ESP traffic"
  default     = false
}

variable "cluster_network_esp_source_ranges" {
  type        = string
  description = "Source IP ranges for ESP traffic"
  default     = ""
}

variable "mgmt_network_cidr" {
  type        = string
  description = "Management external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The Management public IP will be translated to a private address assigned to the active member in this external network."
  default     = "10.0.1.0/24"
}

variable "mgmt_network_name" {
  type        = string
  description = "Management external network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "mgmt_network_subnetwork_name" {
  type         = string
  description  = "Management subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default      = ""
}

variable "mgmt_network_enable_icmp" {
  type        = bool
  description = "Enable ICMP traffic"
  default     = false
}

variable "mgmt_network_icmp_source_ranges" {
  type        = string
  description = "Source IP ranges for ICMP traffic"
  default     = ""
}

variable "mgmt_network_enable_tcp" {
  type        = bool
  description = "Enable TCP traffic"
  default     = false
}

variable "mgmt_network_tcp_source_ranges" {
  type        = string
  description = "Source IP ranges for TCP traffic"
  default     = ""
}

variable "mgmt_network_enable_udp" {
  type        = bool
  description = "Enable UDP traffic"
  default     = false
}

variable "mgmt_network_udp_source_ranges" {
  type        = string
  description = "Source IP ranges for UDP traffic"
  default     = ""
}

variable "mgmt_network_enable_sctp" {
  type        = bool
  description = "Enable SCTP traffic"
  default     = false
}

variable "mgmt_network_sctp_source_ranges" {
  type        = string
  description = "Source IP ranges for SCTP traffic"
  default     = ""
}

variable "mgmt_network_enable_esp" {
  type        = bool
  description = "Enable ESP traffic"
  default     = false
}

variable "mgmt_network_esp_source_ranges" {
  type        = string
  description = "Source IP ranges for ESP traffic"
  default     = ""
}

variable "num_internal_networks" {
  type        = number
  description = "A number in the range 1 - 6 of internal network interfaces."
  default     = 1
}

resource "null_resource" "num_internal_networks_validation" {
  // Will fail if var.num_internal_networks is less than 1 or more than 6
  count = var.num_internal_networks >= 1 && var.num_internal_networks <= 6 ? 0 : "variable num_internal_networks must be a number between 1 and 6. Multiple network interfaces deployment is described in: https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk121637"
}

variable "internal_network1_cidr" {
  type        = string
  description = "1st internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.2.0/24"
}

variable "internal_network1_name" {
  type        = string
  description = "1st internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network1_subnetwork_name" {
  type        = string
  description = "1st internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range. "
  default     = ""
}

variable "internal_network2_cidr" {
  type        = string
  description = "Used only if var.num_internal_networks is 2 or and above - 2nd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.3.0/24"
}

variable "internal_network2_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 2 or and above - 2nd internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network2_subnetwork_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 2 or and above - 2nd internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network3_cidr" {
  type        = string
  description = "Used only if var.num_internal_networks is 3 or and above - 3rd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.4.0/24"
}

variable "internal_network3_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 3 or and above - 3rd internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network3_subnetwork_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 3 or and above - 3rd internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network4_cidr" {
  type        = string
  description = "Used only if var.num_internal_networks is 4 or and above - 4th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.5.0/24"
}

variable "internal_network4_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 4 or and above - 4th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network4_subnetwork_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 4 or and above - 4th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network5_cidr" {
  type        = string
  description = "Used only if var.num_internal_networks is 5 or and above - 5th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.6.0/24"
}

variable "internal_network5_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 5 or and above - 5th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network5_subnetwork_name" {
  type        = string
  description = "Used only if var.num_internal_networks is 5 or and above - 5th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network6_cidr" {
  type        = string
  description = "Used only if var.num_internal_networks equals 6 - 6th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.7.0/24"
}

variable "internal_network6_name" {
  type        = string
  description = "Used only if var.num_internal_networks equals 6 - 6th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network6_subnetwork_name" {
  type        = string
  description = "Used only if var.num_internal_networks equals 6 - 6th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}