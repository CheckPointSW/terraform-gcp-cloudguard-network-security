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

  validate_mgmt_network = var.management_network != "0.0.0.0/0" ? 0 : index("error:", "management_network value cannot be the zero-address.")

  region = substr(var.zone_a, 0, length(var.zone_a) - 2)
  create_cluster_network_condition = var.cluster_network_cidr == "" ? false : true
  create_mgmt_network_condition = var.mgmt_network_cidr == "" ? false : true
  cluster_icmp_traffic_condition = var.cluster_network_icmp_source_ranges != "" ? 1 : 0
  cluster_tcp_traffic_condition = var.cluster_network_tcp_source_ranges != "" ? 1 : 0
  cluster_udp_traffic_condition = var.cluster_network_udp_source_ranges != "" ? 1 : 0
  cluster_sctp_traffic_condition = var.cluster_network_sctp_source_ranges != "" ? 1 : 0
  cluster_esp_traffic_condition = var.cluster_network_esp_source_ranges != "" ? 1 : 0
  mgmt_icmp_traffic_condition = var.mgmt_network_icmp_source_ranges != "" ? 1 : 0
  mgmt_tcp_traffic_condition = var.mgmt_network_tcp_source_ranges != "" ? 1 : 0
  mgmt_udp_traffic_condition = var.mgmt_network_udp_source_ranges != "" ? 1 : 0
  mgmt_sctp_traffic_condition = var.mgmt_network_sctp_source_ranges != "" ? 1 : 0
  mgmt_esp_traffic_condition = var.mgmt_network_esp_source_ranges != "" ? 1 : 0
  create_internal_network1_condition = var.internal_network1_cidr == "" ? false : true
  create_internal_network2_condition = var.internal_network2_cidr == "" && var.num_internal_networks >= 2 ? false : true
  create_internal_network3_condition = var.internal_network3_cidr == "" && var.num_internal_networks >= 3 ? false : true
  create_internal_network4_condition = var.internal_network4_cidr == "" && var.num_internal_networks >= 4 ? false : true
  create_internal_network5_condition = var.internal_network5_cidr == "" && var.num_internal_networks >= 5 ? false : true
  create_internal_network6_condition = var.internal_network6_cidr == "" && var.num_internal_networks == 6 ? false : true
  deploy_with_public_ips = var.deploy_with_public_ips == true ? 1 : 0
}