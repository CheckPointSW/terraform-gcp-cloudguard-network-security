locals {
  create_network_condition = var.network_cidr == "" ? false : true
}

resource "google_compute_network" "network" {
  count = local.create_network_condition ? 1 : 0
  name = "${replace(var.prefix, "--", "-")}-${replace(replace(var.type, "(", ""), ")", "")}"
  auto_create_subnetworks = false
  project = var.project != "" ? var.project : null
}
resource "google_compute_subnetwork" "new_subnetwork" {
  count = local.create_network_condition ? 1 : 0
  name = "${replace(var.prefix, "--", "-")}-${replace(replace(replace(var.type, "(", ""), ")", ""), "--", "-")}-subnet"
  ip_cidr_range = var.network_cidr
  private_ip_google_access = var.private_ip_google_access
  region = var.region
  network = google_compute_network.network[count.index].id
  project = var.project != "" ? var.project : null
}
data "google_compute_subnetwork" "existing_subnetwork" {
  count = local.create_network_condition ? 0 : 1
  name   = var.subnetwork_name
  region = var.region
  project = var.project != "" ? var.project : null
}

data "google_compute_network" "network_name" {
  count = local.create_network_condition ? 0 : 1
  name = var.network_name
  project = var.project != "" ? var.project : null
}