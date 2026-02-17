locals {
  # The marketplace deployment flag. ## DO NOT EDIT ##.
  marketplace = false

  # Use prefix for Terraform deployments, goog_cm_deployment_name for Marketplace
  prefix_effective = local.marketplace ? var.goog_cm_deployment_name : var.prefix

   # Check if the source image is a custom image or not.
  custom_image = !local.marketplace && var.source_image != "" && var.source_image != "latest" ? true : false

  os_version = (
    local.marketplace || local.custom_image ? upper(regex("check-point-(r[0-9]+)", var.source_image)[0]) :
    length(regexall("^r[0-9]+$", lower(var.os_version))) > 0 ? lower(var.os_version) :
    index("error:", "Invalid OS version. Please look at the documentation for valid OS versions.")
  )

  license = (
    local.marketplace || local.custom_image ? contains(split("-", var.source_image), "byol") ? "byol" : "payg" :
    contains(["payg", "byol"], lower(var.license)) ? lower(var.license) : index("error:", "Invalid license type. Allowed values are: PAYG, BYOL")
  )

  region = substr(var.zone, 0, length(var.zone) - 2)
  
  create_external_network_condition = var.external_network_cidr == "" ? false : true
  create_internal_network_condition = var.internal_network_cidr == "" ? false : true
  
  icmp_traffic_condition = var.external_network_icmp_source_ranges != "" ? 1 : 0
  tcp_traffic_condition = var.external_network_tcp_source_ranges != "" ? 1 : 0
  udp_traffic_condition = var.external_network_udp_source_ranges != "" ? 1 : 0
  sctp_traffic_condition = var.external_network_sctp_source_ranges != "" ? 1 : 0
  esp_traffic_condition = var.external_network_esp_source_ranges != "" ? 1 : 0

  icmp_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && var.external_network_icmp_ipv6_source_ranges != "") ? 1 : 0
  tcp_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && var.external_network_tcp_ipv6_source_ranges != "") ? 1 : 0
  udp_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && var.external_network_udp_ipv6_source_ranges != "") ? 1 : 0
  sctp_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && var.external_network_sctp_ipv6_source_ranges != "") ? 1 : 0
  esp_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && var.external_network_esp_ipv6_source_ranges != "") ? 1 : 0
}