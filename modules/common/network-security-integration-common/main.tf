locals{
    mgmt_nic_condition = var.management_nic == "Ephemeral Public IP (eth0)" ? true : false
    mgmt_nic_ip_address_condition = local.mgmt_nic_condition ? "x-chkp-ip-address--public" : "x-chkp-ip-address--private"
    mgmt_nic_interface_condition = "x-chkp-management-interface--eth0"
    admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
    disk_type_condition = var.disk_type == "SSD Persistent Disk" ? "pd-ssd" : var.disk_type == "Standard Persistent Disk" ? "pd-standard" : ""
    service_nic_interface_undefined = "x-chkp-topology-eth1--undefined"
}
provider "google-beta" {
  credentials = var.service_account_path
  project = var.project
  region = var.region
}

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
resource "google_compute_instance_template" "instance_template" {
  name = "${var.prefix}-tmplt-${random_string.random_string.result}"
  machine_type = var.machine_type
  can_ip_forward = true


  disk {
    source_image = "checkpoint-public/${var.image_name}"
    auto_delete = true
    boot = true
    device_name = "${var.prefix}-boot-${random_string.random_string.result}"
    disk_type = local.disk_type_condition
    disk_size_gb = var.disk_size
    mode = "READ_WRITE"
    type = "PERSISTENT"
  }

  network_interface {
    network = var.mgmt_network[0]
    subnetwork = var.mgmt_subnetwork[0]
    dynamic "access_config" {
      for_each = local.mgmt_nic_condition ? [
        1] : []
      content {
        network_tier = local.mgmt_nic_condition ? "PREMIUM" : "STANDARD"
      }
    }
  }

  network_interface {
    network = var.security_network[0]
    subnetwork = var.security_subnetwork[0]
  }

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    preemptible = false
  }

  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"]
  }
  tags = [
    format("x-chkp-management--%s", var.management_name),
    format("x-chkp-template--%s", var.configuration_template_name),
    "checkpoint-gateway",
    local.mgmt_nic_ip_address_condition,
    local.mgmt_nic_interface_condition,
    local.service_nic_interface_undefined
    ]

  metadata = local.admin_SSH_key_condition ? {
    serial-port-enable = "true"
    instanceSSHKey = var.admin_SSH_key
    adminPasswordSourceMetadata = var.generate_password ?random_string.generated_password.result : ""
  } : {
    serial-port-enable = "true"
    adminPasswordSourceMetadata = var.generate_password?random_string.generated_password.result : ""
  }

  metadata_startup_script = templatefile("${path.module}/../startup-script.sh", {
    // script's arguments
    generatePassword = var.generate_password
    config_url = ""
    config_path = ""
    sicKey = ""
    allowUploadDownload = var.allow_upload_download
    templateName = "network_security_integration_tf"
    templateVersion = "20230910"
    templateType = "terraform"
    mgmtNIC = var.management_nic
    hasInternet = "false"
    enableMonitoring = var.enable_monitoring
    shell = var.admin_shell
    installation_type = "Network Security Integration"
    computed_sic_key = var.sic_key
    managementGUIClientNetwork = ""
    primary_cluster_address_name = ""
    secondary_cluster_address_name = ""
    secondary_cluster_address_name = ""
    managementNetwork = ""
    numAdditionalNICs = ""
    smart_1_cloud_token = ""
    name = ""
    zoneConfig = ""
    region = ""
    os_version = var.os_version
    maintenance_mode_password_hash = var.maintenance_mode_password_hash
  })
}
resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  region = var.region
  name = "${var.prefix}-igm-${random_string.random_string.result}"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name = "${var.prefix}-tmplt"
  }
  base_instance_name = "${var.prefix}-${random_string.random_string.result}"
}
resource "google_compute_region_autoscaler" "autoscaler" {
  region = var.region
  name = "${var.prefix}-autoscaler-${random_string.random_string.result}"
  target = google_compute_region_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas = var.instances_max_group_size
    min_replicas = var.instances_min_group_size
    cooldown_period = 90

    cpu_utilization {
      target = var.cpu_usage/100
    }
  }
}

module "load_balancer" {
  source = "../internal-load-balancer"
  project = var.project
  prefix = var.prefix
  network = var.security_network[0]
  subnetwork = var.security_subnetwork[0]
  region = var.region
  protocol = "UDP"
  ip_protocol = "UDP"
  ports = [6081]
  instance_group = google_compute_region_instance_group_manager.instance_group_manager.instance_group
  intercept_deployment_zones = var.intercept_deployment_zones
  connection_draining_timeout = var.connection_draining_timeout
}

resource "google_network_security_intercept_deployment_group" "network_security_intercept_deployment_group" {
  provider                      = google-beta
  project                       = var.project
  intercept_deployment_group_id = "${var.prefix}-intercept-deployment-group"
  location                      = "global"
  network                       = var.security_network[0]
}

resource "google_network_security_intercept_deployment" "network_security_intercept_deployment" {
  provider                   = google-beta
  for_each                   = toset(var.intercept_deployment_zones)
  intercept_deployment_id    = "${var.prefix}-intercept-deployment-${each.key}"
  location                   = each.key
  project                    = var.project 
  forwarding_rule            = module.load_balancer.forwarding_rule[each.key]
  intercept_deployment_group = google_network_security_intercept_deployment_group.network_security_intercept_deployment_group.id
}

resource "google_network_security_intercept_endpoint_group" "network_security_intercept_endpoint_group" {
  provider                      = google-beta
  intercept_endpoint_group_id   = "${var.prefix}-intercept-endpoint-group"
  project                       = var.project
  intercept_deployment_group    = google_network_security_intercept_deployment_group.network_security_intercept_deployment_group.id
  location                      = "global"
}

resource "google_network_security_intercept_endpoint_group_association" "network_security_intercept_endpoint_group_association" {
  provider                                = google-beta
  intercept_endpoint_group_association_id = "${var.prefix}-intercept-endpoint-group-association"
  intercept_endpoint_group                = google_network_security_intercept_endpoint_group.network_security_intercept_endpoint_group.id
  network                                 = var.service_network[0]
  location                                = "global"
  project                                 = var.project 
}

resource "google_network_security_security_profile" "network_security_profile" {
    provider                 = google-beta
    name                     = "${var.prefix}-network-security-profile"
    custom_intercept_profile {
      intercept_endpoint_group = google_network_security_intercept_endpoint_group.network_security_intercept_endpoint_group.id
    } 
    type                     = "CUSTOM_INTERCEPT"
    parent                   = "organizations/${var.organization_id}" 
}

resource "google_network_security_security_profile_group" "network_security_profile_group" {
  provider                  = google-beta
  name                      = "${var.prefix}-network-security-profile-group"
  custom_intercept_profile  = google_network_security_security_profile.network_security_profile.id
  parent                    = "organizations/${var.organization_id}"
}

resource "google_compute_network_firewall_policy" "consumer_policy" {
  name    = "${var.prefix}-consumer-policy"
  project = var.project
}

resource "google_compute_network_firewall_policy_rule" "ingress_network_firewall_policy" {
  provider                = google-beta
  priority                = 10
  action                  = "apply_security_profile_group"
  firewall_policy         = google_compute_network_firewall_policy.consumer_policy.id
  security_profile_group  = "//networksecurity.googleapis.com/${google_network_security_security_profile_group.network_security_profile_group.id}"
  direction               = "INGRESS"
  match {
    layer4_configs {
      ip_protocol = "all"
    }
    src_ip_ranges = ["0.0.0.0/0"]
    dest_ip_ranges = ["0.0.0.0/0"]
  }
}

resource "google_compute_network_firewall_policy_rule" "egress_network_firewall_policy" {
  provider                = google-beta
  priority                = 11
  action                  = "apply_security_profile_group"
  firewall_policy         = google_compute_network_firewall_policy.consumer_policy.id
  security_profile_group  = "//networksecurity.googleapis.com/${google_network_security_security_profile_group.network_security_profile_group.id}"
  direction               = "EGRESS"
  match {
    layer4_configs {
      ip_protocol = "all"
    }
    src_ip_ranges = ["0.0.0.0/0"]
    dest_ip_ranges = ["0.0.0.0/0"]
  }
}

resource "google_compute_network_firewall_policy_association" "network_firewall_policy_association" {
  name               = "${var.prefix}-consumer-policy-association"
  firewall_policy    = google_compute_network_firewall_policy.consumer_policy.id
  attachment_target  = var.service_network[0]
  project            = var.project
}