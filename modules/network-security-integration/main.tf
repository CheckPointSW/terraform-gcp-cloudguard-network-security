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
module "common" {
  source = "../common/common"
  installation_type = "Network Security Integration"
  os_version = var.os_version
  image_name = var.image_name
  admin_shell = var.admin_shell
  license = var.license
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

module "service_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${var.prefix}-service-network-${random_string.nsi_random_string.result}"
    type = "nsi"
    network_cidr = var.service_network_cidr
    private_ip_google_access = true
    region = var.region
    network_name = var.service_network_name
    subnetwork_name = var.service_subnetwork_name
}

module "network_ICMP_firewall_rules" {
  count = local.ICMP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = var.ICMP_traffic
  rule_name = "${var.prefix}-icmp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}
module "network_TCP_firewall_rules" {
  count = local.TCP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = var.TCP_traffic
  rule_name = "${var.prefix}-tcp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}
module "network_UDP_firewall_rules" {
  count = local.UDP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = var.UDP_traffic
  rule_name = "${var.prefix}-udp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}
module "network_SCTP_firewall_rules" {
  count = local.SCTP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = var.UDP_traffic
  rule_name = "${var.prefix}-sctp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
}
module "network_ESP_firewall_rules" {
  count = local.ESP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = var.ESP_traffic
  rule_name = "${var.prefix}-esp-${random_string.random_string.result}"
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
  source = "../common/network-security-integration-common"

  service_account_path = var.service_account_path
  project = var.project
  organization_id = var.organization_id

  # --- Check Point---
  sic_key = var.sic_key
  prefix = var.prefix
  image_name = var.image_name
  os_version = var.os_version
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
  service_network = local.create_service_network_condition ? module.service_network_and_subnet.new_created_network_link : module.service_network_and_subnet.existing_network_link
  service_subnetwork = local.create_service_network_condition ? module.service_network_and_subnet.new_created_subnet_link : [var.service_subnetwork_name]
  ICMP_traffic = var.ICMP_traffic
  TCP_traffic = var.TCP_traffic
  UDP_traffic = var.UDP_traffic
  SCTP_traffic = var.SCTP_traffic
  ESP_traffic = var.ESP_traffic

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