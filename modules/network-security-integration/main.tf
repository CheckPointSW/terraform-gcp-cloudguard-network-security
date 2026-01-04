resource "random_string" "nsi_random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

module "last_image" {
  count = local.custom_image ? 0 : 1
  source = "../common/compute-image"
  os_version = local.os_version
  image_type = "gw-${local.license}-nsi"
}

locals {
  image_name = local.custom_image ? var.source_image : module.last_image[0].image
}

module "common" {
  source = "../common/common"
  installation_type = "Network Security Integration"
  os_version = upper(local.os_version)
  image_name = local.image_name
  admin_shell = var.admin_shell
  license = upper(local.license)
  admin_SSH_key = var.admin_SSH_key
}

module "mgmt_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${var.prefix}-mgmt-network-${random_string.nsi_random_string.result}"
    type = "nsi"
    network_cidr = var.mgmt_network_cidr
    private_ip_google_access = true
    region = var.region
    network_name = var.mgmt_network_name
    subnetwork_name = var.mgmt_subnetwork_name
}
module "security_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${var.prefix}-security-network-${random_string.nsi_random_string.result}"
    type = "nsi"
    network_cidr = var.security_network_cidr
    private_ip_google_access = true
    region = var.region
    network_name = var.security_network_name
    subnetwork_name = var.security_subnetwork_name
}
module "mgmt_network_icmp_firewall_rules" {
  count = local.mgmt_icmp_traffic_condition == true ? 1 : 0
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = split(", ", var.mgmt_network_icmp_traffic)
  rule_name = "${var.prefix}-mgmt-icmp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_network_tcp_firewall_rules" {
  count = local.mgmt_tcp_traffic_condition == true ? 1 : 0
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = split(", ", var.mgmt_network_tcp_traffic)
  rule_name = "${var.prefix}-mgmt-tcp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_network_udp_firewall_rules" {
  count = local.mgmt_udp_traffic_condition == true ? 1 : 0
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = split(", ", var.mgmt_network_udp_traffic)
  rule_name = "${var.prefix}-mgmt-udp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}
module "mgmt_network_sctp_firewall_rules" {
  count = local.mgmt_sctp_traffic_condition == true ? 1 : 0
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = split(", ", var.mgmt_network_sctp_traffic)
  rule_name = "${var.prefix}-mgmt-sctp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_network_esp_firewall_rules" {
  count = local.mgmt_esp_traffic_condition == true ? 1 : 0
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = split(", ", var.mgmt_network_esp_traffic)
  rule_name = "${var.prefix}-mgmt-esp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "security_network_allow_udp_6081_firewall" {
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = ["${module.security_network_and_subnet.gateway_address}/32"]
  ports = ["6081"]
  rule_name = "${var.prefix}-data-network-allow-udp-6081"
  network = local.create_security_network_condition ? module.security_network_and_subnet.new_created_network_link : module.security_network_and_subnet.existing_network_link
}

module "security_network_allow_tcp_8117_hc_ranges_firewall" {
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  ports = ["8117"]
  rule_name = "${var.prefix}-data-network-allow-tcp-8117-hc-ranges"
  network = local.create_security_network_condition ? module.security_network_and_subnet.new_created_network_link : module.security_network_and_subnet.existing_network_link
}

module "network-security-integration" {
  source = "./common"

  project = var.project

  # --- Check Point---
  sic_key = var.sic_key
  prefix = var.prefix
  image_name = local.image_name
  os_version = upper(local.os_version)
  management_nic = var.management_nic
  management_name = var.management_name
  configuration_template_name = var.configuration_template_name
  generate_password  = var.generate_password
  admin_SSH_key = var.admin_SSH_key
  maintenance_mode_password_hash = var.maintenance_mode_password_hash
  admin_shell = var.admin_shell
  allow_upload_download = var.allow_upload_download

  # --- Networking ---
  region = var.region
  intercept_deployment_zones = var.intercept_deployment_zones
  mgmt_network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  mgmt_subnetwork  = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_subnet_link : [var.mgmt_subnetwork_name]
  security_network = local.create_security_network_condition ? module.security_network_and_subnet.new_created_network_link : module.security_network_and_subnet.existing_network_link
  security_subnetwork = local.create_security_network_condition ? module.security_network_and_subnet.new_created_subnet_link : [var.security_subnetwork_name]
  mgmt_network_icmp_traffic = var.mgmt_network_icmp_traffic
  mgmt_network_tcp_traffic = var.mgmt_network_tcp_traffic
  mgmt_network_udp_traffic = var.mgmt_network_udp_traffic
  mgmt_network_sctp_traffic = var.mgmt_network_sctp_traffic
  mgmt_network_esp_traffic = var.mgmt_network_esp_traffic

  # --- Instance Configuration ---
  machine_type = var.machine_type
  cpu_usage = var.cpu_usage
  instances_min_group_size = var.instances_min_group_size
  instances_max_group_size = var.instances_max_group_size
  disk_type = var.disk_type
  disk_size = var.disk_size
  enable_monitoring = var.enable_monitoring
  connection_draining_timeout = var.connection_draining_timeout
}
