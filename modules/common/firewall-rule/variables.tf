variable "protocol" {
  type = string
  description = "The IP protocol to which this rule applies."
}
variable "source_ranges" {
  type = list(string)
  description = "(Optional) Source IP ranges for the protocol traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable this protocol traffic."
  default = []
  
  validation {
    condition = alltrue([
      for range in var.source_ranges : 
      range == "" ||
      can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$", range))
    ])
    error_message = "Source IP ranges must be a valid IPv4 CIDR or a comma-separated list of valid IPv4 CIDRs (e.g., '10.0.0.0/24' or '10.0.0.0/24, 192.168.1.0/24')."
  }
}
variable "rule_name" {
  type = string
  description = "Firewall rule name."
}
variable "network" {
  type = list(string)
  description = "The name or self_link of the network to attach this firewall to."
}
variable "target_tags" {
  description = "List of target tags for the firewall rule"
  type = list(string)
  default = ["checkpoint-gateway"]
}
variable "ports" {
  description = "List of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. "
  type = list(number)
  default = []
  
}
variable "project" {
  type = string
  description = "The project in which the firewall rule resource belongs. If empty, the provider project is used."
  default = ""
}