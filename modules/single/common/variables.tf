variable "project" {
  type = string
  description = "Personal project id. The project indicates the default GCP project all of your resources will be created in."
  default = ""
}

variable "zone" {
  type = string
  description = "The zone determines what computing resources are available and where your data is stored and used"
  default = "us-central1-a"
}

variable "image_name" {
  type = string
  description = "The single gateway and management image name."
}

variable "os_version" {
  type = string
  description = "GAIA OS version."
  default = "R82"
}

variable "installation_type" {
  type = string
  description = "Installation type and version."
  default = "Gateway only"
}

variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-single-tf-"
}

variable "machine_type" {
  type = string
  default = "n1-standard-4"
}

variable "network" {
  type = list(string)
  description = "The network determines what network traffic the instance can access"
  default = ["default"]
}

variable "subnetwork" {
  type = list(string)
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ["default"]
}

variable "network_project" {
  type = string
  description = "The project ID where the network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "disk_type" {
  type = string
  description ="Disk type"
  default = "SSD Persistent Disk"
}

variable "disk_size" {
  type = number
  description ="Disk size in GB"
  default = 100
}

variable "generate_password" {
  type = bool
  description ="Automatically generate an administrator password"
  default = false
}

variable "management_nic" {
  type = string
  description = "Management Interface - Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1)."
  default = "Ephemeral Public IP (eth0)"
}

variable "allow_upload_download" {
  type = string
  description ="Allow download from/upload to Check Point"
  default = true
}

variable "enable_monitoring" {
  type = bool
  description ="Enable Stackdriver monitoring"
  default = false
}

variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
}

variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the template instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type = string
  default = ""
}

variable "sic_key" {
  type = string
  description ="The Secure Internal Communication one time secret used to set up trust between the single gateway object and the management server"
  default = ""
}

variable "management_gui_client_network" {
  type = string
  description ="Allowed GUI clients	"
  default = "0.0.0.0/0"
}

variable "smart_1_cloud_token" {
  type = string
  description ="(Optional) Smart-1 cloud token to connect this Gateway to Check Point's Security Management as a Service"
  default = ""
}

variable "num_additional_networks" {
  type = number
  description ="Number of additional network interfaces"
  default = 1
}

variable "external_ip" {
  type = string
  description = "External IP address type"
  default = "static"
}

variable "internal_network1_network" {
  type = list(string)
  description = "1st internal network ID in the chosen zone."
  default = []
}

variable "internal_network1_subnetwork" {
  type = list(string)
  description = "1st internal subnet ID in the chosen network."
  default = []
}

variable "internal_network1_project" {
  type = string
  description = "The project ID where the 1st internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network2_network" {
  type = list(string)
  description = "2nd internal network ID in the chosen zone."
  default = []
}

variable "internal_network2_project" {
  type = string
  description = "The project ID where the 2nd internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}
variable "internal_network2_subnetwork" {
  type = list(string)
  description = "2nd internal subnet ID in the chosen network."
  default = []

}

variable "internal_network3_network" {
  type = list(string)
  description = "3rd internal network ID in the chosen zone."
  default = []
}
variable "internal_network3_project" {
  type = string
  description = "The project ID where the 3rd internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network3_subnetwork" {
  type = list(string)
  description = "3rd internal subnet ID in the chosen network."

  default = []
}

variable "internal_network4_network" {
  type = list(string)
  description = "4th internal network ID in the chosen zone."
  default = []
}

variable "internal_network4_project" {
  type = string
  description = "The project ID where the 4th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}
variable "internal_network4_subnetwork" {
  type = list(string)

  description = "4th internal subnet ID in the chosen network."
  default = []
}

variable "internal_network5_network" {
  type = list(string)
  description = "5th internal network ID in the chosen zone."
  default = []
}
variable "internal_network5_project" {
  type = string
  description = "The project ID where the 5th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network5_subnetwork" {

  type = list(string)
  description = "5th internal subnet ID in the chosen network."
  default = []
}

variable "internal_network6_network" {
  type = list(string)
  description = "6th internal network ID in the chosen zone."
  default = []
}


variable "internal_network6_project" {
  type = string
  description = "The project ID where the 6th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}
variable "internal_network6_subnetwork" {
  type = list(string)
  description = "6th internal subnet ID in the chosen network."
  default = []
}

variable "internal_network7_network" {
  type = list(string)
  description = "7th internal network ID in the chosen zone."
  default = []
}

variable "internal_network7_project" {
  type = string
  description = "The project ID where the 7th internal network is located. For Shared VPC, this is the host project ID."
  default = ""
}

variable "internal_network7_subnetwork" {
  type = list(string)
  description = "7th internal subnet ID in the chosen network."
  default = []
}
