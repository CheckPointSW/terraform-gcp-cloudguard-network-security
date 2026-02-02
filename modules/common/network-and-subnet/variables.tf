variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-tf-ha"
}
variable "type" {
  type = string
}
variable "network_cidr" {
  type = string
  description = "External subnet CIDR. If the variable's value is not empty double quotes, a new network will be created."
  default = "10.0.0.0/24"
}
variable "private_ip_google_access" {
  type = bool
  description = "When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access."
  default = true
}
variable "region" {
  type = string
  default = "us-central1"
}
variable "network_name" {
  type = string
  description = "External network ID in the chosen zone. The network determines what network traffic the instance can access.If you have specified a CIDR block at var.network_cidr, this network name will not be used."
  default = ""
}
variable "subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork's range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "project" {
  type = string
  description = "The project in which the resource (network/subnetwork) belongs. If empty, the provider project is used."
  default = ""
}

variable "ip_stack_type" {
  type = string
  description = "The IP stack type for this network. Possible values are IPV4_ONLY and IPV4_IPV6."
  default = "IPV4_ONLY"
  validation {
    condition = contains(["IPV4_ONLY", "IPV4_IPV6"], var.ip_stack_type)
    error_message = "ip_stack_type must be either IPV4_ONLY or IPV4_IPV6."
  }
}

variable "ipv6_access_type" {
  type = string
  description = "The IPv6 access type for this subnetwork. Possible values are EXTERNAL and INTERNAL."
  default = "EXTERNAL"
  validation {
    condition = contains(["EXTERNAL", "INTERNAL"], var.ipv6_access_type)
    error_message = "ipv6_access_type must be either EXTERNAL or INTERNAL."
  }
}

variable "network_ipv6_ula" {
  type = string
  description = "The IPv6 ULA range for the internal network. Required when stack_type is IPV4_IPV6. Must be a valid ULA range (fd20::/20) with /48 prefix."
  default = ""
  
  validation {
    condition = var.network_ipv6_ula == "" || can(regex("^fd20::/48$|^fd20:(?:[0-9a-fA-F]{1,3}|0[0-9a-fA-F]{3})::/48$|^fd20:(?:[0-9a-fA-F]{1,3}|0[0-9a-fA-F]{3}):(?:[0-9a-fA-F]{1,4})::/48$", var.network_ipv6_ula))
    error_message = "The network_ipv6_ula must be a valid IPv6 ULA range in Google Cloud's fd20::/20 space with /48 prefix (e.g., 'fd20::/48', 'fd20:0abc::/48', 'fd20:123:def::/48')."
  }
}