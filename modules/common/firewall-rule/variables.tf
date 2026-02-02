variable "protocol" {
  type = string
  description = "The IP protocol to which this rule applies."
}
variable "source_ranges" {
  type = list(string)
  description = "(Optional) IPv4 source IP ranges for the protocol traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to disable this protocol traffic."
  default = []
  
  validation {
    condition = alltrue([
      for range in var.source_ranges : 
      range == "" ||
      can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$", range))
    ])
    error_message = "Source IP ranges must be valid IPv4 CIDR notation (e.g., '10.0.0.0/24', '192.168.1.0/24')."
  }
}

variable "source_ranges_ipv6" {
  type = list(string)
  description = "(Optional) IPv6 source IP ranges for the protocol traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to disable this protocol traffic."
  default = []
  
  validation {
    condition = alltrue([
      for range in var.source_ranges_ipv6 : 
      range == "" ||
      can(regex("^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|::)/(12[0-8]|1[0-1][0-9]|[1-9]?[0-9])$", range))
    ])
    error_message = "Source IP ranges must be valid IPv6 CIDR notation (e.g., '2001:db8::/32', 'fd00:1234:5678::/48')."
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