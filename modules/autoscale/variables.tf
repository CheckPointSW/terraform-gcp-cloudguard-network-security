variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

// Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  description = "The name of the deployment and VM instance."
  type        = string
  default     = "chkp-tf-mig"
}

variable "prefix" {
  type        = string
  description = "The prefix to use for resource naming. Used when deploying via Terraform (not Marketplace)."
  default     = "chkp-tf-mig"
}

variable "source_image" {
  description = "The image name for the disk for the VM instance."
  type        = string
  default     = "projects/checkpoint-public/global/images/check-point-r82-gw-byol-mig-777-991002015-v20260215"
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

variable "zone" {
  type        = string
  description = "The zone for the solution to be deployed."
  default     = "us-central1-a"
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

variable "external_network_cidr" {
  description = "The external network CIDR"
  type        = string
  default = "10.0.1.0/24"
}

variable "internal_network_cidr" {
  description = "The internal network CIDR"
  type        = string
  default = "10.0.2.0/24"
}

variable "external_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
  default = ""
}
variable "external_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork's range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}

variable "internal_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
  default = ""
}
variable "internal_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork's range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}

variable "management_nic" {
  description = "Autoscaling Security Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1)."
  type        = string
  default     = "Ephemeral Public IP (eth0)"
}

variable "management_name" {
  description = "The name of the Security Management Server as appears in autoprovisioning configuration"
  type        = string
  default     = "checkpoint-management"
}

variable "configuration_template_name" {
  description = "Specify the provisioning configuration template name (for autoprovisioning)"
  type        = string
  default     = "gcp-asg-autoprov-tmplt"
}

variable "admin_SSH_key" {
  description = "This key will be used to connect to every gateway instance created by the managed instance group. This key will replace all project-wide SSH keys"
  type        = string
  default     = ""
}

variable "network_defined_by_routes" {
  description = "Set eth1 topology to define the networks behind this interface by the routes configured on the gateway"
  type        = bool
  default     = true
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

variable "instances_min_group_size" {
  type        = number
  default     = 2
}

variable "instances_max_group_size" {
  type        = number
  default     = 10
}

variable "cpu_usage" {
  type        = number
  description = "Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance."
  default     = 60
}

variable "sic_key" {
  type        = string
  description = "The Secure Internal Communication one time secret used to set up trust between the gateway object and the management server"
  default     = ""
}

variable "external_network_icmp_source_ranges" {
  type        = string
  description = "Source IP ranges for ICMP traffic"
  default     = ""
}

variable "external_network_tcp_source_ranges" {
  type        = string
  description = "Source IP ranges for TCP traffic"
  default     = ""
}

variable "external_network_udp_source_ranges" {
  type        = string
  description = "Source IP ranges for UDP traffic"
  default     = ""
}

variable "external_network_sctp_source_ranges" {
  type        = string
  description = "Source IP ranges for SCTP traffic"
  default     = ""
}

variable "external_network_esp_source_ranges" {
  type        = string
  description = "Source IP ranges for ESP traffic"
  default     = ""
}

variable "external_network_project" {
  type = string
  description = "The project in which the external network and subnetwork belongs. If it is not provided, the provider project is used."
  default = ""
}

variable "internal_network_project" {
  type = string
  description = "The project in which the internal network and subnetwork belongs. If it is not provided, the provider project is used."
  default = ""
}

# IPv6 Dual Stack Support Variables
variable "ip_stack_type" {
  description = "The stack type for the networks (IPV4_ONLY, IPV4_IPV6)"
  type        = string
  default     = "IPV4_ONLY"
  validation {
    condition     = contains(["IPV4_ONLY", "IPV4_IPV6"], var.ip_stack_type)
    error_message = "The ip_stack_type must be either IPV4_ONLY or IPV4_IPV6."
  }
}

variable "external_network_ipv6_ula" {
  description = "IPv6 ULA CIDR range for external network. If empty, Google will auto-generate one."
  type        = string
  default     = ""
}

variable "internal_network_ipv6_ula" {
  description = "IPv6 ULA CIDR range for internal network. If empty, Google will auto-generate one."
  type        = string
  default     = ""
}

# IPv6 Firewall Rules Variables
variable "external_network_icmp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for ICMP traffic"
  default     = ""
}

variable "external_network_tcp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for TCP traffic"
  default     = ""
}

variable "external_network_udp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for UDP traffic"
  default     = ""
}

variable "external_network_sctp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for SCTP traffic"
  default     = ""
}

variable "external_network_esp_ipv6_source_ranges" {
  type        = string
  description = "Source IPv6 ranges for ESP traffic"
  default     = ""
}

# Load Balancer Configuration
variable "deploy_external_lb" {
  type        = bool
  description = "Deploy external Network Load Balancer for the MIG. The external LB distributes internet traffic to the Security Gateways."
  default     = true
}

variable "deploy_internal_lb" {
  type        = bool
  description = "Deploy internal Network Load Balancer for the MIG. The internal LB acts as a next hop for routing traffic through the Security Gateways."
  default     = true
}
