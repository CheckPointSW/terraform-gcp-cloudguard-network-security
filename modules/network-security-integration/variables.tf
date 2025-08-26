# Check Point CloudGuard IaaS Network Security Integration - Terraform Template

# --- Google Provider ---
variable "service_account_path" {
  type = string
  description = "User service account path in JSON format - From the service account key page in the Cloud Console choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location is stored."
  default = ""
}
variable "project" {
  type = string
  description = "Personal project id. The project indicates the default GCP project all of your resources will be created in."
  default = ""
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project)) && length(var.project) >= 6 && length(var.project) <= 30
    error_message = "The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphenst and cannot end with a hyphen."
  }
}

variable "organization_id" {
  type = string
  description = "Organization ID - The organization ID is a unique identifier for your organization in GCP. It is used to manage resources and permissions within your organization."
  default = ""
}

# --- Check Point---
variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-tf-nsi"
}
variable "license" {
  type = string
  description = "Checkpoint license (BYOL)."
  default = "BYOL"
  validation {
    condition = contains(["BYOL"] , var.license)
    error_message = "Allowed licenses are 'BYOL'"
  }
}
variable "image_name" {
  type = string
  description = "The NSI image name (e.g. check-point-r8120-gw-byol-nsi-631-991001866-v20250731)."
}
variable "os_version" {
  type = string
  description = "GAIA OS version"
  default = "R8120"
}
variable "management_nic" {
  type = string
  description = "Management Interface - Autoscaling Security Gateways in GCP can be managed by the ephemeral public IP or by the private IP of the Management interface (eth0)."
  default = "Ephemeral Public IP (eth0)"
  validation {
    condition = contains(["Ephemeral Public IP (eth0)", "Private IP (eth0)"], var.management_nic)
    error_message = "Allowed values for management_nic are 'Ephemeral Public IP (eth0)', 'Private IP (eth0)'"
  }
}
variable "management_name" {
  type = string
  description = "The name of the Security Management Server as appears in autoprovisioning configuration. (Please enter a valid Security Management name including ascii characters only)"
  default = "tf-checkpoint-management"
}
variable "configuration_template_name" {
  type = string
  description = "Specify the provisioning configuration template name (for autoprovisioning). (Please enter a valid autoprovisioing configuration template name including ascii characters only)"
  default = "tf-asg-autoprov-tmplt"
}
variable "generate_password" {
  type = bool
  description = "Automatically generate an administrator password"
  default = false
}
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type = string
  default = ""
}
variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
  validation {
    condition     = contains(["/etc/cli.sh", "/bin/bash", "/bin/tcsh", "/bin/csh"], var.admin_shell)
    error_message = "Valid shells are '/etc/cli.sh', '/bin/bash', '/bin/tcsh', '/bin/csh'"
  }
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}

variable "sic_key" {
  type = string
  description ="The Secure Internal Communication one time secret used to set up trust between the gatewayes objects and the management server"
  default = ""
  validation {
    condition = can(regex("^[a-z0-9A-Z]{12,30}$", var.sic_key))
    error_message = "Only alphanumeric characters are allowed, and the value must be 12-30 characters long."
  }
}

# --- Networking ---
data "google_compute_regions" "available_regions" {
}
variable "region" {
  type = string
  default = "us-central1"
}

data "google_compute_zones" "available_zones" {
  region = var.region
}

variable "intercept_deployment_zones" {
  type = list(string)
  description = "The list of zones for which a network security intercept deployment will be deployed. The zones must be in the same region as the deployment."
  default = ["us-central1-a"]
  validation {
    condition = length(var.intercept_deployment_zones) > 0
    error_message = "The intercept_deployment_zones variable must contain at least one zone."
  }
  validation {
    condition = length([
      for zone in var.intercept_deployment_zones :
      zone if contains(data.google_compute_zones.available_zones.names, zone)
    ]) == length(var.intercept_deployment_zones)
    error_message = "One or more specified zones are not available in the selected region ${var.region}. Please choose zones within this region."
  }
}

variable "mgmt_network_cidr" {
  type = string
  description = "The range of external addresses that are owned by this network, only IPv4 is supported (e.g. \"10.0.0.0/8\" or \"192.168.0.0/16\")."
  default = "10.0.1.0/24"
}
variable "security_network_cidr" {
  type = string
  description = "The range of internal addresses that are owned by this network, only IPv4 is supported (e.g. \"10.0.0.0/8\" or \"192.168.0.0/16\")."
  default = "10.0.2.0/24"
}
variable "ICMP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ICMP traffic."
  default = []
}
variable "TCP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable TCP traffic."
  default = []
}
variable "UDP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable UDP traffic."
  default = []
}
variable "SCTP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable SCTP traffic."
  default = []
}
variable "ESP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ESP traffic."
  default = []
}

# --- Instance Configuration ---
variable "machine_type" {
  type = string
  default = "n2-standard-4"
}
variable "cpu_usage" {
  type = number
  description = "Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance."
  default = 60
}
resource "null_resource" "cpu_usage_validation" {
  // Will fail if var.cpu_usage is less than 10 or more than 90
  count = var.cpu_usage >= 10 && var.cpu_usage <= 90 ? 0 : "variable cpu_usage must be a number between 10 and 90"
}
variable "instances_min_group_size" {
  type = number
  description = "The minimal number of instances"
  default = 2
}
variable "instances_max_group_size" {
  type = number
  description = "The maximal number of instances"
  default = 10
}
variable "mgmt_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
  default = ""
}
variable "mgmt_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork's range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
}
variable "security_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
}
variable "security_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork's range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
}
variable "disk_type" {
  type = string
  description = "Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency."
  default = "SSD Persistent Disk"
  validation {
    condition = contains(["SSD Persistent Disk" , "Standard Persistent Disk"] , var.disk_type)
    error_message = "Allowed values for diskType are : 'SSD Persistent Disk' , 'Standard Persistent Disk'"
  }
}
variable "disk_size" {
  type = number
  description = "Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space."
  default = 100
}
resource "null_resource" "disk_size_validation" {
  // Will fail if var.disk_size is less than 100 or more than 4096
  count = var.disk_size >= 100 && var.disk_size <= 4096 ? 0 : "variable disk_size must be a number between 100 and 4096"
}
variable "enable_monitoring" {
  type = bool
  description = "Enable Stackdriver monitoring"
  default = false
}

variable "service_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
  default = ""
}

variable "service_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork's range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}

variable "service_network_cidr" {
  type = string
  description = "The range of external addresses that are owned by this network, only IPv4 is supported (e.g. \"10.0.0.0/8\" or \"192.168.0.0/16\")."
  default = "10.0.3.0/24"
}

variable "connection_draining_timeout" {
    type = number
    description = "The time, in seconds, that the load balancer waits for active connections to complete before fully removing an instance from the backend group. The default value is 300 seconds."
    default = 300
}