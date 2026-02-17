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
  project = var.project
  name = "${var.prefix}-tmplt-${random_string.random_string.result}"
  machine_type = var.machine_type
  can_ip_forward = true

  disk {
    source_image = startswith(var.image_name, "projects/") ? var.image_name : "checkpoint-public/${var.image_name}"
    auto_delete = true
    boot = true
    device_name = "${var.prefix}-boot-${random_string.random_string.result}"
    disk_type = local.disk_type_condition
    disk_size_gb = var.disk_size
    mode = "READ_WRITE"
    type = "PERSISTENT"
  }

  network_interface {
    network = var.external_network[0]
    subnetwork = var.external_subnetwork[0]
    subnetwork_project = var.external_network_project != "" ? var.external_network_project : null
    stack_type = var.ip_stack_type
    dynamic "access_config" {
      for_each = local.mgmt_nic_condition ? [
        1] : []
      content {
        network_tier = local.mgmt_nic_condition ? "PREMIUM" : "STANDARD"
      }
    }
    dynamic "ipv6_access_config" {
      for_each = var.ip_stack_type == "IPV4_IPV6" && local.mgmt_nic_condition ? [1] : []
      content {
        network_tier = "PREMIUM"
      }
    }
  }

  network_interface {
    network = var.internal_network[0]
    subnetwork = var.internal_subnetwork[0]
    subnetwork_project = var.internal_network_project != "" ? var.internal_network_project : null
    stack_type = var.ip_stack_type
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

  tags = compact([
  format("x-chkp-management--%s", var.management_name),
  format("x-chkp-template--%s", var.configuration_template_name),
  "checkpoint-gateway",
  local.mgmt_nic_ip_address_condition,
  local.mgmt_nic_interface_condition,
  local.network_defined_by_routes_condition,
  local.network_defined_by_routes_settings_condition,
  var.ip_stack_type == "IPV4_IPV6" ? "x-chkp-mig--enabled" : null,
  var.ip_stack_type == "IPV4_IPV6" ? "x-chkp-ip-version--dual-stack" : "x-chkp-ip-version--ipv4-only",
])


  metadata = local.admin_SSH_key_condition ? {
    serial-port-enable = "true"
    instanceSSHKey = var.admin_SSH_key
    adminPasswordSourceMetadata = var.generate_password ?random_string.generated_password.result : ""
  } : {
    serial-port-enable = "true"
    adminPasswordSourceMetadata = var.generate_password?random_string.generated_password.result : ""
  }

  metadata_startup_script = templatefile("${path.module}/startup-script.sh", {
    // script's arguments
    generatePassword = var.generate_password
    config_url = ""
    config_path = ""
    sicKey = ""
    allowUploadDownload = var.allow_upload_download
    templateName = var.ip_stack_type == "IPV4_IPV6" ? "autoscale_dual_stack" : "autoscale"
    templateVersion = "1.0.13"
    templateType = "terraform"
    mgmtNIC = var.management_nic
    hasInternet = "false"
    enableMonitoring = var.enable_monitoring
    shell = var.admin_shell
    installation_type = "AutoScale"
    computed_sic_key = var.sic_key
    managementGUIClientNetwork = ""
    primary_cluster_address_name = ""
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
  project = var.project
  region = var.region
  name = "${var.prefix}-igm-${random_string.random_string.result}"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name = "${var.prefix}-tmplt"
  }
  base_instance_name = "${var.prefix}-${random_string.random_string.result}"
}

resource "google_compute_region_autoscaler" "autoscaler" {
  project = var.project
  region = var.region
  name = "${var.prefix}-autoscaler-${random_string.random_string.result}"
  target = google_compute_region_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas = var.instances_max_group_size
    min_replicas = var.instances_min_group_size
    cooldown_period = 90

    cpu_utilization {
      target = var.cpu_usage / 100
    }
  }
}