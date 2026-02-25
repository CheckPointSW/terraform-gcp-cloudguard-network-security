resource "random_string" "random_string" {
  length  = 5
  special = false
  upper   = false
  keepers = {}
}

module "last_image" {
  count = local.custom_image ? 0 : 1
  source = "../common/compute-image"
  os_version = local.os_version
  image_type = local.image_installation_type
}

locals {
  image_name = local.marketplace || local.custom_image ? var.source_image : module.last_image[0].image
}

module "common" {
  source = "../common/common"
  installation_type = local.installation_type
  os_version = upper(local.os_version)
  image_name = local.image_name
  admin_shell = var.admin_shell
  license = upper(local.license)
  admin_SSH_key = var.public_ssh_key
  boot_disk_type = var.boot_disk_type
  externalIP = var.external_ip
}

module "network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${local.prefix_effective}-${random_string.random_string.result}"
    type = local.installation_type_short
    network_cidr = var.network_cidr
    network_ipv6_ula = var.network_ipv6_ula
    private_ip_google_access = true
    region = local.region
    network_name = var.network_name
    subnetwork_name = var.subnetwork_name
    ip_stack_type = var.ip_stack_type
    ipv6_access_type = var.external_ip != "none" ? "EXTERNAL" : "INTERNAL"
    project = var.network_project
}

module "network_icmp_firewall_rules" {
  count = local.ICMP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = split(", ", var.network_icmp_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-icmp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_tcp_firewall_rules" {
  count = local.TCP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = split(", ", var.network_tcp_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-tcp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_udp_firewall_rules" {
  count = local.UDP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = split(", ", var.network_udp_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-udp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_sctp_firewall_rules" {
  count = local.SCTP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = split(", ", var.network_sctp_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-sctp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_esp_firewall_rules" {
  count = local.ESP_traffic_condition 
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = split(", ", var.network_esp_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-esp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_icmp_ipv6_firewall_rules" {
  count = local.ICMP_ipv6_traffic_condition
  source = "../common/firewall-rule"
  protocol = "58"
  source_ranges_ipv6 = split(", ", var.network_icmp_ipv6_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-icmp-ipv6-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_tcp_ipv6_firewall_rules" {
  count = local.TCP_ipv6_traffic_condition
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges_ipv6 = split(", ", var.network_tcp_ipv6_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-tcp-ipv6-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_udp_ipv6_firewall_rules" {
  count = local.UDP_ipv6_traffic_condition
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges_ipv6 = split(", ", var.network_udp_ipv6_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-udp-ipv6-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_sctp_ipv6_firewall_rules" {
  count = local.SCTP_ipv6_traffic_condition
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges_ipv6 = split(", ", var.network_sctp_ipv6_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-sctp-ipv6-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "network_esp_ipv6_firewall_rules" {
  count = local.ESP_ipv6_traffic_condition 
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges_ipv6 = split(", ", var.network_esp_ipv6_source_ranges)
  rule_name = "${local.prefix_effective}-${local.installation_type_short}-esp-ipv6-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  target_tags = local.firewall_target_tags
  project = var.network_project
}

module "internal_network1_and_subnet" {
  count = local.create_internal_network1_condition ? 1 : 0
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network1"
  network_cidr = var.internal_network1_cidr
  network_ipv6_ula = var.internal_network1_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network1_name
  subnetwork_name = var.internal_network1_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network1_project
}

module "internal_network2_and_subnet" {
  count = local.create_internal_network2_condition ? 1 : 0
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network2"
  network_cidr = var.internal_network2_cidr
  network_ipv6_ula = var.internal_network2_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network2_name
  subnetwork_name = var.internal_network2_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network2_project
}

module "internal_network3_and_subnet" {
  count = var.num_additional_networks < 3 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network3"
  network_cidr = var.internal_network3_cidr
  network_ipv6_ula = var.internal_network3_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network3_name
  subnetwork_name = var.internal_network3_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network3_project
}

module "internal_network4_and_subnet" {
  count = var.num_additional_networks < 4 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network4"
  network_cidr = var.internal_network4_cidr
  network_ipv6_ula = var.internal_network4_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network4_name
  subnetwork_name = var.internal_network4_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network4_project
}

module "internal_network5_and_subnet" {
  count = var.num_additional_networks < 5 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network5"
  network_cidr = var.internal_network5_cidr
  network_ipv6_ula = var.internal_network5_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network5_name
  subnetwork_name = var.internal_network5_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network5_project
}

module "internal_network6_and_subnet" {
  count = var.num_additional_networks < 6 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network6"
  network_cidr = var.internal_network6_cidr
  network_ipv6_ula = var.internal_network6_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network6_name
  subnetwork_name = var.internal_network6_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network6_project
}

module "internal_network7_and_subnet" {
  count = var.num_additional_networks < 7 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${local.prefix_effective}-${random_string.random_string.result}"
  type = "internal-network7"
  network_cidr = var.internal_network7_cidr
  network_ipv6_ula = var.internal_network7_ipv6_ula
  private_ip_google_access = false
  region = local.region
  network_name = var.internal_network7_name
  subnetwork_name = var.internal_network7_subnetwork_name
  ip_stack_type = var.ip_stack_type
  ipv6_access_type = "INTERNAL"
  project = var.internal_network7_project
}

module "single" {
  source               = "./common"
  project              = var.project_id

  # Check Point Deployment
  image_name                       = local.image_name
  os_version                       = upper(local.os_version)
  installation_type                = local.installation_type
  prefix                           = local.prefix_effective
  management_nic                   = var.management_interface
  ip_stack_type                    = var.ip_stack_type
  admin_shell                      = var.admin_shell
  admin_SSH_key                    = var.public_ssh_key
  maintenance_mode_password_hash   = var.maintenance_mode_password
  generate_password                = var.generate_password
  allow_upload_download            = var.allow_upload_download
  sic_key                          = var.sic_key
  management_gui_client_network    = var.management_gui_client_network

  # Smart-1 Cloud
  smart_1_cloud_token = var.smart_1_cloud_token

  # Networking
  zone                    = var.zone
  network                 = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  subnetwork              = local.create_network_condition ? module.network_and_subnet.new_created_subnet_link : [var.subnetwork_name]
  network_project         = var.network_project
  num_additional_networks = var.num_additional_networks
  external_ip             = var.external_ip

  #Internal networks
  internal_network1_network = var.num_additional_networks < 1 ? [] : local.create_internal_network1_condition ? module.internal_network1_and_subnet[0].new_created_network_link : [var.internal_network1_name]
  internal_network1_subnetwork = var.num_additional_networks < 1 ? [] : local.create_internal_network1_condition ? module.internal_network1_and_subnet[0].new_created_subnet_link : [var.internal_network1_subnetwork_name]
  internal_network1_project = var.internal_network1_project
  internal_network2_network = var.num_additional_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_network_link : [var.internal_network2_name]
  internal_network2_subnetwork = var.num_additional_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_subnet_link : [var.internal_network2_subnetwork_name]
  internal_network2_project = var.internal_network2_project
  internal_network3_network = var.num_additional_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_network_link : [var.internal_network3_name]
  internal_network3_subnetwork = var.num_additional_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_subnet_link : [var.internal_network3_subnetwork_name]
  internal_network3_project = var.internal_network3_project
  internal_network4_network = var.num_additional_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_network_link : [var.internal_network4_name]
  internal_network4_subnetwork = var.num_additional_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_subnet_link : [var.internal_network4_subnetwork_name]
  internal_network4_project = var.internal_network4_project
  internal_network5_network = var.num_additional_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_network_link : [var.internal_network5_name]
  internal_network5_subnetwork = var.num_additional_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_subnet_link : [var.internal_network5_subnetwork_name]
  internal_network5_project = var.internal_network5_project
  internal_network6_network = var.num_additional_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_network_link : [var.internal_network6_name]
  internal_network6_subnetwork = var.num_additional_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_subnet_link : [var.internal_network6_subnetwork_name]
  internal_network6_project = var.internal_network6_project
  internal_network7_network = var.num_additional_networks < 7 ? [] : local.create_internal_network7_condition ? module.internal_network7_and_subnet[0].new_created_network_link : [var.internal_network7_name]
  internal_network7_subnetwork = var.num_additional_networks < 7 ? [] : local.create_internal_network7_condition ? module.internal_network7_and_subnet[0].new_created_subnet_link : [var.internal_network7_subnetwork_name]
  internal_network7_project = var.internal_network7_project

  # Instances configuration
  machine_type      = var.machine_type
  disk_type         = var.boot_disk_type
  disk_size         = var.boot_disk_size
  enable_monitoring = var.enable_monitoring
}