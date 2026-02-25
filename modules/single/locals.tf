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

  region = substr(var.zone, 0, length(var.zone) - 2)

  license = (
    local.marketplace || local.custom_image ? contains(split("-", var.source_image), "byol") ? "byol" : "payg" :
    contains(["payg", "byol"], lower(var.license)) ? lower(var.license) : index("error:", "Invalid license type. Allowed values are: PAYG, BYOL")
  )

  installation_type = (
    local.marketplace || local.custom_image ? (length(regexall("check-point-[^-]+-gw-${local.license}(-single)?", var.source_image)) > 0 ? "Gateway only" :
    length(regexall("check-point-[^-]+-${local.license}-mc", var.source_image)) > 0 ? "Manual Configuration" :
    length(regexall("check-point-[^-]+-${local.license}-sa", var.source_image)) > 0 ? "Gateway and Management (Standalone)" :
    length(regexall("check-point-[^-]+-${local.license}", var.source_image)) > 0 ? "Management only" : ""
    ) : var.installation_type
  )

  image_installation_type = (
    local.installation_type == "Gateway only" ? "gw-${local.license}-single" :
    local.installation_type == "Manual Configuration" ? "${local.license}-mc" :
    local.installation_type == "Gateway and Management (Standalone)" ? "${local.license}-sa" :
    local.installation_type == "Management only" ? "${local.license}" : ""
  )

  create_network_condition = var.network_cidr == "" ? false : true

  ICMP_traffic_condition = length(var.network_icmp_source_ranges) == 0 ? 0 : 1
  TCP_traffic_condition = length(var.network_tcp_source_ranges) == 0 ? 0 : 1
  UDP_traffic_condition = length(var.network_udp_source_ranges) == 0 ? 0 : 1
  SCTP_traffic_condition = length(var.network_sctp_source_ranges) == 0 ? 0 : 1
  ESP_traffic_condition = length(var.network_esp_source_ranges) == 0 ? 0 : 1

  ICMP_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && length(var.network_icmp_ipv6_source_ranges) > 0) ? 1 : 0
  TCP_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && length(var.network_tcp_ipv6_source_ranges) > 0) ? 1 : 0
  UDP_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && length(var.network_udp_ipv6_source_ranges) > 0) ? 1 : 0
  SCTP_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && length(var.network_sctp_ipv6_source_ranges) > 0) ? 1 : 0
  ESP_ipv6_traffic_condition = (var.ip_stack_type == "IPV4_IPV6" && length(var.network_esp_ipv6_source_ranges) > 0) ? 1 : 0

  validate_num_additional_networks = var.num_additional_networks >= 0 && var.num_additional_networks <= 7 ? 0 : index("error:", "The number of internal networks must be between 0 and 7.")

  create_internal_network1_condition = var.internal_network1_cidr != "" && var.num_additional_networks >= 1 ? true : false
  create_internal_network2_condition = var.internal_network2_cidr != "" && var.num_additional_networks >= 2 ? true : false
  create_internal_network3_condition = var.internal_network3_cidr != "" && var.num_additional_networks >= 3 ? true : false
  create_internal_network4_condition = var.internal_network4_cidr != "" && var.num_additional_networks >= 4 ? true : false
  create_internal_network5_condition = var.internal_network5_cidr != "" && var.num_additional_networks >= 5 ? true : false
  create_internal_network6_condition = var.internal_network6_cidr != "" && var.num_additional_networks >= 6 ? true : false
  create_internal_network7_condition = var.internal_network7_cidr != "" && var.num_additional_networks >= 7 ? true : false

  // Validate variables
  validate_installation_type = contains(["Gateway only", "Manual Configuration", "Gateway and Management (Standalone)", "Management only"], local.installation_type) ? 0 : index("error:", "Invalid installation type. Allowed values are: Gateway only, Manual Configuration, Gateway and Management (Standalone), Management only")

  validate_management_without_public_ip = local.installation_type == "Management only" && var.external_ip == "none" ? index("error:" , "using management externalIP cannot be none") : 0

  validate_management_additional_networks = local.installation_type == "Management only" && var.num_additional_networks > 0  ? index("error:" , "If you create a management only installation, you cant have additional network") : 0

  validate_gateway_additional_networks = local.installation_type == "Gateway only" && var.num_additional_networks <= 0  ? index("error:" , "If you create a gateway only installation, you need to have additional networks 1-7") : 0

  validate_sic_key = var.sic_key != "" && length(regexall("^[a-z0-9A-Z]{12,30}$", var.sic_key)) == 0 ? index("error:", "Invalid SIC key. Must be between 12 and 30 alphanumeric characters.") : 0

  firewall_target_tags = (
    local.installation_type == "Gateway only" ? ["checkpoint-gateway"] :
    local.installation_type == "Manual Configuration" ? ["checkpoint-manual"] :
    ["checkpoint-management"]
  )

  # Shortened installation type for resource naming to avoid exceeding GCP name length limits
  installation_type_short = (
    local.installation_type == "Gateway only" ? "gateway" :
    local.installation_type == "Manual Configuration" ? "manual" :
    local.installation_type == "Gateway and Management (Standalone)" ? "standalone" :
    local.installation_type == "Management only" ? "management" : ""
  )
}