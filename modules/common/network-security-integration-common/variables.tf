# Check Point CloudGuard IaaS Autoscaling - Terraform Template

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
}

variable "organization_id" {
  type = string
  description = "Organization ID - The organization ID is a unique identifier for your organization. It is used to identify your organization in the Google Cloud Console and in API requests."
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
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
variable "generate_password" {
  type = bool
  description = "Automatically generate an administrator password"
  default = false
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
}

# --- Networking ---
data "google_compute_regions" "available_regions" {
}
variable "region" {
  type = string
  default = "us-central1"
}
variable "intercept_deployment_zones" {
  type = list(string)
  description = "The list of zones for which a network security intercept deployment will be deployed. The zones must be in the same region as the deployment."
  default = ["us-central1-a"]
}
variable "mgmt_network" {
  type = list(string)
  description = "The network determines what network traffic the instance can access"
  default = ["default"]
}
variable "mgmt_subnetwork" {
  type = list(string)
  description = "The subnetwork determines what network traffic the instance can access"
  default = ["default"]
}

variable "security_network" {
  type = list(string)
  description = "The network determines what network traffic the instance can access"
  default = ["default"]
}
variable "security_subnetwork" {
  type = list(string)
  description = "The subnetwork determines what network traffic the instance can access"
  default = ["default"]
}

variable "service_network" {
  type = list(string)
  description = "The network determines what network traffic the instance can access"
  default = ["default"]
}

variable "service_subnetwork" {
  type = list(string)
  description = "The subnetwork determines what network traffic the instance can access"
  default = ["default"]
  
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
  default = "n1-standard-4"
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
variable "disk_type" {
  type = string
  description = "Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency."
  default = "SSD Persistent Disk"
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

variable "connection_draining_timeout" {
    type = number
    description = "The time, in seconds, that the load balancer waits for active connections to complete before fully removing an instance from the backend group. The default value is 300 seconds."
    default = 300
}