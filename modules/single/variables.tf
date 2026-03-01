variable "project_id" {
  type        = string
  description = "The ID of the project in which to provision resources."
}

// Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  type        = string
  description = "The name of the deployment and VM instance."
  default     = "chkp-single-tf"
}

variable "prefix" {
  type        = string
  description = "The prefix to use for resource naming. Used when deploying via Terraform (not Marketplace)."
  default     = "chkp-single-tf"
}


variable "source_image" {
  type        = string
  description = "The image name for the disk for the VM instance."
  default     = "projects/checkpoint-public/global/images/check-point-r82-gw-byol-single-777-991002015-v20260215"
}

variable "os_version" {
  type        = string
  description = "The OS version of the image to use for the VM instance."
  default     = "R82"
}

variable "license" {
  type        = string
  description = "The license type for the Check Point image. Allowed values are: BYOL, PAYG."
  default     = "BYOL"
}

variable "installation_type" {
  type        = string
  description = "The installation type of the Check Point image. Allowed values are: Gateway only, Manual Configuration, Gateway and Management (Standalone), Management only."
  default     = "Gateway only"  
}

variable "zone" {
  type        = string
  description = "The zone determines what computing resources are available and where your data is stored and used."
  default     = "us-central1-a"
}

variable "machine_type" {
  type        = string
  description = "The machine type to create, e.g. e2-small"
  default     = "n1-standard-4"
}

variable "boot_disk_type" {
  type        = string
  description = "The boot disk type for the VM instance."
  default     = "SSD Persistent Disk"
}

variable "boot_disk_size" {
  type        = number
  description = "The boot disk size for the VM instance in GBs"
  default     = 100
}

variable "public_ssh_key" {
  type        = string
  description = "This key will be used to connect to every gateway instance created by the managed instance group. This key will replace all project-wide SSH keys"
  default     = ""
}

variable "admin_shell" {
  type        = string
  description = "Change the admin shell to enable advanced command line configuration."
  default     = "/etc/cli.sh"
}

variable "allow_upload_download" {
  type        = bool
  description = "Approve to automatically download product updates and to share statistical data with Check Point for product improvement purpose. For more information see sk111080"
  default     = true
}

variable "generate_password" {
  type        = bool
  description = "To manage the environment's security, administrators can connect to the Management Server with SmartConsole clients and via the Gaia WebUI using this password"
  default     = false
}

variable "enable_monitoring" {
  type        = bool
  default     = false
}

variable "sic_key" {
  type        = string
  description = "The Secure Internal Communication one time secret used to set up trust between the  gateway object and the management server"
  default     = ""
}

variable "maintenance_mode_password" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type = string
  default = ""
}

variable "smart_1_cloud_token" {
  type        = string
  description = "(Optional) Smart-1 cloud token for member A to connect this Gateway to Check Point's Security Management as a Service"
  default     = ""
}

variable "management_interface" {
  type = string
  description = "Management Interface - Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1)."
  default = "Ephemeral Public IP (eth0)"
}

variable "network_cidr" {
  type        = string
  description = "External subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The Cluster public IP will be translated to a private address assigned to the active member in this external network."
  default     = "10.0.0.0/24"
}

variable "network_name" {
  type = string
  description = "External network ID in the chosen zone. The network determines what network traffic the instance can access."
  default = ""
}

variable "subnetwork_name" {
  type        = string
  description = "External subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default      = ""
}

variable "network_project" {
  type = string
  description = "The project ID where the network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "network_ipv6_ula" {
  type        = string
  description = "Gateway network IPv6 ULA CIDR range (must be within fd20::/20 with /48 prefix). Leave empty for auto-generated range (recommended). Example: fd20:1234:5678::/48"
  default     = ""
}

variable "ip_stack_type" {
  type        = string
  description = "IP stack type for the networks and instance interfaces. IPV4_ONLY for IPv4 only, IPV4_IPV6 for dual-stack (IPv4 + IPv6)"
  default     = "IPV4_ONLY"
}

variable "network_icmp_source_ranges" {
  type        = string
  description = "Source IP ranges for ICMP traffic"
  default     = ""
}

variable "network_tcp_source_ranges" {
  type        = string
  description = "Source IP ranges for TCP traffic"
  default     = ""
}

variable "network_udp_source_ranges" {
  type        = string
  description = "Source IP ranges for UDP traffic"
  default     = ""
}

variable "network_sctp_source_ranges" {
  type        = string
  description = "Source IP ranges for SCTP traffic"
  default     = ""
}

variable "network_esp_source_ranges" {
  type        = string
  description = "Source IP ranges for ESP traffic"
  default     = ""
}

variable "network_icmp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for ICMPv6 traffic"
  default     = ""
}

variable "network_tcp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for TCP traffic"
  default     = ""
}

variable "network_udp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for UDP traffic"
  default     = ""
}

variable "network_sctp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for SCTP traffic"
  default     = ""
}

variable "network_esp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for ESP traffic"
  default     = ""
}

variable "external_ip" {
  type = string
  description = "External IP address type"
  default = "static"
}

variable "num_additional_networks" {
  type = number
  description = "A number in the range 0 - 7 of internal network interfaces."
  default = 0
}

variable "management_gui_client_network" {
  type = string
  description ="Allowed GUI clients	"
  default = "0.0.0.0/0"
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

variable "internal_network1_project" {
  type = string
  description = "The project ID where the 1st internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network1_ipv6_ula" {
  type        = string
  description = "1st internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:1235::/48"
  default     = ""
}

variable "internal_network2_cidr" {
  type        = string
  description = "Used only if var.num_additional_networks is 2 or and above - 2nd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.3.0/24"
}

variable "internal_network2_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 2 or and above - 2nd internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network2_subnetwork_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 2 or and above - 2nd internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network2_project" {
  type = string
  description = "The project ID where the 2nd internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network2_ipv6_ula" {
  type        = string
  description = "Used only if var.num_additional_networks is 2 or and above - 2nd internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:1236::/48"
  default     = ""
}

variable "internal_network3_cidr" {
  type        = string
  description = "Used only if var.num_additional_networks is 3 or and above - 3rd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.4.0/24"
}

variable "internal_network3_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 3 or and above - 3rd internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network3_subnetwork_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 3 or and above - 3rd internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network3_project" {
  type = string
  description = "The project ID where the 3rd internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network3_ipv6_ula" {
  type        = string
  description = "Used only if var.num_additional_networks is 3 or and above - 3rd internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:1237::/48"
  default     = ""
}

variable "internal_network4_cidr" {
  type        = string
  description = "Used only if var.num_additional_networks is 4 or and above - 4th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.5.0/24"
}

variable "internal_network4_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 4 or and above - 4th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network4_subnetwork_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 4 or and above - 4th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network4_project" {
  type = string
  description = "The project ID where the 4th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network4_ipv6_ula" {
  type        = string
  description = "Used only if var.num_additional_networks is 4 or and above - 4th internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:1238::/48"
  default     = ""
}

variable "internal_network5_cidr" {
  type        = string
  description = "Used only if var.num_additional_networks is 5 or and above - 5th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.6.0/24"
}

variable "internal_network5_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 5 or and above - 5th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network5_subnetwork_name" {
  type        = string
  description = "Used only if var.num_additional_networks is 5 or and above - 5th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network5_project" {
  type = string
  description = "The project ID where the 5th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network5_ipv6_ula" {
  type        = string
  description = "Used only if var.num_additional_networks is 5 or and above - 5th internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:1239::/48"
  default     = ""
}

variable "internal_network6_cidr" {
  type        = string
  description = "Used only if var.num_additional_networks equals 6 - 6th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.7.0/24"
}

variable "internal_network6_name" {
  type        = string
  description = "Used only if var.num_additional_networks equals 6 - 6th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network6_subnetwork_name" {
  type        = string
  description = "Used only if var.num_additional_networks equals 6 - 6th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network6_project" {
  type = string
  description = "The project ID where the 6th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network6_ipv6_ula" {
  type        = string
  description = "Used only if var.num_additional_networks equals 6 - 6th internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:123a::/48"
  default     = ""
}

variable "internal_network7_cidr" {
  type        = string
  description = "Used only if var.num_additional_networks equals 7 - 7th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default     = "10.0.7.0/24"
}

variable "internal_network7_name" {
  type        = string
  description = "Used only if var.num_additional_networks equals 7 - 7th internal network ID in the chosen zone. The network determines what network traffic the instance can access."
  default     = ""
}

variable "internal_network7_subnetwork_name" {
  type        = string
  description = "Used only if var.num_additional_networks equals 7 - 7th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork's range."
  default     = ""
}

variable "internal_network7_project" {
  type = string
  description = "The project ID where the 7th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network7_ipv6_ula" {
  type        = string
  description = "Used only if var.num_additional_networks equals 7 - 7th internal subnet IPv6 CIDR range for ULA (Unique Local Address). Must be within fd20::/20 (valid range: fd20:0000:0000::/48 to fd20:0fff:ffff::/48) and have /48 prefix. Example: fd20:0abc:123b::/48"
  default     = ""
}