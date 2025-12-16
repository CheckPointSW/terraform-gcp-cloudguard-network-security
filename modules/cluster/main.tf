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
  image_type = "gw-${local.license}-cluster"
}

locals {
  image_name = local.marketplace || local.custom_image ? var.source_image : module.last_image[0].image
}

module "common" {
  source = "../common/common"
  installation_type = "Cluster"
  os_version = upper(local.os_version)
  image_name = local.image_name
  admin_shell = var.admin_shell
  license = upper(local.license)
  boot_disk_type = var.boot_disk_type
}

module "cluster_network_and_subnet" {
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "cluster"
  network_cidr = var.cluster_network_cidr
  private_ip_google_access = true
  region = local.region
  network_name = var.cluster_network_name
  subnetwork_name = var.cluster_network_subnetwork_name
}

module "cluster_icmp_firewall_rules" {
  count = local.cluster_icmp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = split(", ", var.cluster_network_icmp_source_ranges)
  rule_name = "${local.prefix_effective}-cluster-icmp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
}

module "cluster_tcp_firewall_rules" {
  count = local.cluster_tcp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = split(", ", var.cluster_network_tcp_source_ranges)
  rule_name = "${local.prefix_effective}-cluster-tcp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
}

module "cluster_udp_firewall_rules" {
  count = local.cluster_udp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = split(", ", var.cluster_network_udp_source_ranges)
  rule_name = "${local.prefix_effective}-cluster-udp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
}

module "cluster_sctp_firewall_rules" {
  count = local.cluster_sctp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = split(", ", var.cluster_network_sctp_source_ranges)
  rule_name = "${local.prefix_effective}-cluster-sctp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
}

module "cluster_esp_firewall_rules" {
  count = local.cluster_esp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = split(", ", var.cluster_network_esp_source_ranges)
  rule_name = "${local.prefix_effective}-cluster-esp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
}

module "mgmt_network_and_subnet" {
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "mgmt"
  network_cidr = var.mgmt_network_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.mgmt_network_name
  subnetwork_name = var.mgmt_network_subnetwork_name
}

module "mgmt_icmp_firewall_rules" {
  count = local.mgmt_icmp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = split(", ", var.mgmt_network_icmp_source_ranges)
  rule_name = "${local.prefix_effective}-mgmt-icmp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_tcp_firewall_rules" {
  count = local.mgmt_tcp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = split(", ", var.mgmt_network_tcp_source_ranges)
  rule_name = "${local.prefix_effective}-mgmt-tcp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_udp_firewall_rules" {
  count = local.mgmt_udp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = split(", ", var.mgmt_network_udp_source_ranges)
  rule_name = "${local.prefix_effective}-mgmt-udp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_sctp_firewall_rules" {
  count = local.mgmt_sctp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = split(", ", var.mgmt_network_sctp_source_ranges)
  rule_name = "${local.prefix_effective}-mgmt-sctp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "mgmt_esp_firewall_rules" {
  count = local.mgmt_esp_traffic_condition
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = split(", ", var.mgmt_network_esp_source_ranges)
  rule_name = "${local.prefix_effective}-mgmt-esp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}

module "internal_network1_and_subnet" {
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network1"
  network_cidr = var.internal_network1_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network1_name
  subnetwork_name = var.internal_network1_subnetwork_name
}

module "internal_network2_and_subnet" {
  count = var.num_internal_networks < 2 ? 0 : 1
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network2"
  network_cidr = var.internal_network2_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network2_name
  subnetwork_name = var.internal_network2_subnetwork_name
}

module "internal_network3_and_subnet" {
  count = var.num_internal_networks < 3 ? 0 : 1
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network3"
  network_cidr = var.internal_network3_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network3_name
  subnetwork_name = var.internal_network3_subnetwork_name
}

module "internal_network4_and_subnet" {
  count = var.num_internal_networks < 4 ? 0 : 1
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network4"
  network_cidr = var.internal_network4_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network4_name
  subnetwork_name = var.internal_network4_subnetwork_name
}

module "internal_network5_and_subnet" {
  count = var.num_internal_networks < 5 ? 0 : 1
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network5"
  network_cidr = var.internal_network5_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network5_name
  subnetwork_name = var.internal_network5_subnetwork_name
}

module "internal_network6_and_subnet" {
  count = var.num_internal_networks < 6 ? 0 : 1
  source = "../common/network-and-subnet"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network6"
  network_cidr = var.internal_network6_cidr
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network6_name
  subnetwork_name = var.internal_network6_subnetwork_name
}

resource "google_compute_address" "primary_cluster_ip_ext_address" {
  count = local.deploy_with_public_ips
  name = "${local.prefix_effective}-primary-cluster-address-${random_string.random_string.result}"
  region = local.region
}

resource "google_compute_address" "secondary_cluster_ip_ext_address" {
  count = local.deploy_with_public_ips
  name = "${local.prefix_effective}-secondary-cluster-address-${random_string.random_string.result}"
  region = local.region
}

resource "random_string" "generated_password" {
  length = 12
  special = false
}

module "members_a_b" {
  source = "./common/members-a-b"
  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  region = local.region
  zone_a = var.zone_a
  zone_b = var.zone_b
  machine_type = var.machine_type
  disk_size = var.boot_disk_size
  disk_type = var.boot_disk_type
  image_name = local.image_name
  cluster_network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  cluster_network_subnetwork = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_subnet_link : [var.cluster_network_subnetwork_name]
  mgmt_network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  mgmt_network_subnetwork = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_subnet_link : [var.mgmt_network_subnetwork_name]
  num_internal_networks = var.num_internal_networks
  internal_network1_network = local.create_internal_network1_condition ? module.internal_network1_and_subnet.new_created_network_link : [var.internal_network1_name]
  internal_network1_subnetwork = local.create_internal_network1_condition ? module.internal_network1_and_subnet.new_created_subnet_link : [var.internal_network1_subnetwork_name]
  internal_network2_network = var.num_internal_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_network_link : [var.internal_network2_name]
  internal_network2_subnetwork = var.num_internal_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_subnet_link : [var.internal_network2_subnetwork_name]
  internal_network3_network = var.num_internal_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_network_link : [var.internal_network3_name]
  internal_network3_subnetwork = var.num_internal_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_subnet_link : [var.internal_network3_subnetwork_name]
  internal_network4_network = var.num_internal_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_network_link : [var.internal_network4_name]
  internal_network4_subnetwork = var.num_internal_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_subnet_link : [var.internal_network4_subnetwork_name]
  internal_network5_network = var.num_internal_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_network_link : [var.internal_network5_name]
  internal_network5_subnetwork = var.num_internal_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_subnet_link : [var.internal_network5_subnetwork_name]
  internal_network6_network = var.num_internal_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_network_link : [var.internal_network6_name]
  internal_network6_subnetwork = var.num_internal_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_subnet_link : [var.internal_network6_subnetwork_name]
  admin_SSH_key = var.public_ssh_key
  generated_admin_password = var.generate_password ? random_string.generated_password.result : ""
  project = var.project_id
  generate_password = var.generate_password
  sic_key = var.sic_key
  allow_upload_download = var.allow_upload_download
  enable_monitoring = var.enable_monitoring
  admin_shell = var.admin_shell
  management_network = var.management_network
  primary_cluster_address_name = local.deploy_with_public_ips == 1 ? google_compute_address.primary_cluster_ip_ext_address[0].name : "no-public-ip"
  secondary_cluster_address_name = local.deploy_with_public_ips == 1 ? google_compute_address.secondary_cluster_ip_ext_address[0].name : "no-public-ip"
  smart_1_cloud_token_a = var.smart_1_cloud_token_a
  smart_1_cloud_token_b = var.smart_1_cloud_token_b
  os_version = local.os_version
  maintenance_mode_password_hash = var.maintenance_mode_password
  deploy_with_public_ips = var.deploy_with_public_ips
}