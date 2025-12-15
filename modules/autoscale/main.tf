resource "random_string" "generated_password" {
  length = 12
  special = false
}

resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

resource "random_string" "mig_random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

module "last_image" {
  count = local.custom_image ? 0 : 1
  source = "../common/compute-image"
  os_version = upper(local.os_version)
  image_type = "gw-${local.license}-mig"
}

locals {
  image_name = local.marketplace || local.custom_image ? var.source_image : module.last_image[0].image
}

module "common" {
  source = "../common/common"
  installation_type = "AutoScale"
  os_version = upper(local.os_version)
  image_name = local.image_name
  admin_shell = var.admin_shell
  license = upper(local.license)
  admin_SSH_key = var.admin_SSH_key
  boot_disk_type = var.boot_disk_type
}

module "external_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${local.prefix_effective}-ext-network-${random_string.mig_random_string.result}"
    type = "autoscale"
    network_cidr = var.external_network_cidr
    private_ip_google_access = true
    region = local.region
    network_name = var.external_network_name
    subnetwork_name = var.external_subnetwork_name
    project = var.external_network_project
}

module "internal_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${local.prefix_effective}-int-network-${random_string.mig_random_string.result}"
    type = "autoscale"
    network_cidr = var.internal_network_cidr
    private_ip_google_access = true
    region = local.region
    network_name = var.internal_network_name
    subnetwork_name = var.internal_subnetwork_name
    project = var.internal_network_project
}

module "icmp_firewall_rules" {
  count = local.icmp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = split(", ", var.external_network_icmp_source_ranges)
  rule_name = "${local.prefix_effective}-icmp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  project = var.external_network_project
}

module "tcp_firewall_rules" {
  count = local.tcp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = split(", ", var.external_network_tcp_source_ranges)
  rule_name = "${local.prefix_effective}-tcp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  project = var.external_network_project
}

module "udp_firewall_rules" {
  count = local.udp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = split(", ", var.external_network_udp_source_ranges)
  rule_name = "${local.prefix_effective}-udp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  project = var.external_network_project
}

module "sctp_firewall_rules" {
  count = local.sctp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = split(", ", var.external_network_sctp_source_ranges)
  rule_name = "${local.prefix_effective}-sctp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  project = var.external_network_project
}

module "esp_firewall_rules" {
  count = local.esp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = split(", ", var.external_network_esp_source_ranges)
  rule_name = "${local.prefix_effective}-esp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  project = var.external_network_project
}

module "autoscale" {
  source = "./common"

  project = var.project_id
  external_network_project = var.external_network_project
  internal_network_project = var.internal_network_project

  # --- Check Point---
  sic_key = var.sic_key
  prefix = local.prefix_effective
  image_name = local.image_name
  os_version = upper(local.os_version)
  management_nic = var.management_nic
  management_name = var.management_name
  configuration_template_name = var.configuration_template_name
  generate_password  = var.generate_password
  admin_SSH_key = var.admin_SSH_key
  maintenance_mode_password_hash = var.maintenance_mode_password
  network_defined_by_routes = var.network_defined_by_routes
  admin_shell = var.admin_shell
  allow_upload_download = var.allow_upload_download

  # --- Networking ---
  region = local.region
  external_network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  external_subnetwork  = local.create_external_network_condition ? module.external_network_and_subnet.new_created_subnet_link : [var.external_subnetwork_name]
  internal_network = local.create_internal_network_condition ? module.internal_network_and_subnet.new_created_network_link : module.internal_network_and_subnet.existing_network_link
  internal_subnetwork = local.create_internal_network_condition ? module.internal_network_and_subnet.new_created_subnet_link : [var.internal_subnetwork_name]
  ICMP_traffic = [var.external_network_icmp_source_ranges]
  TCP_traffic = [var.external_network_tcp_source_ranges]
  UDP_traffic = [var.external_network_udp_source_ranges]
  SCTP_traffic = [var.external_network_sctp_source_ranges]
  ESP_traffic = [var.external_network_esp_source_ranges]

  # --- Instance Configuration ---
  machine_type = var.machine_type
  cpu_usage = var.cpu_usage
  instances_min_group_size = var.instances_min_group_size
  instances_max_group_size = var.instances_max_group_size
  disk_type = var.boot_disk_type
  disk_size = var.boot_disk_size
  enable_monitoring = var.enable_monitoring
}