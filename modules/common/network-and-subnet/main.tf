locals {
  create_network_condition = var.network_cidr == "" ? false : true
}

resource "google_compute_network" "network" {
  count = local.create_network_condition ? 1 : 0
  name = "${replace(var.prefix, "--", "-")}-${replace(replace(var.type, "(", ""), ")", "")}"
  auto_create_subnetworks = false
  enable_ula_internal_ipv6 = var.ip_stack_type == "IPV4_IPV6" && var.ipv6_access_type == "INTERNAL" ? true : false
  # If network_ipv6_ula is provided, use it; otherwise let GCP auto-generate
  internal_ipv6_range = var.ip_stack_type == "IPV4_IPV6" && var.ipv6_access_type == "INTERNAL" && var.network_ipv6_ula != "" ? var.network_ipv6_ula : null
  project = var.project != "" ? var.project : null
}
resource "google_compute_subnetwork" "new_subnetwork" {
  count = local.create_network_condition ? 1 : 0
  name = "${replace(var.prefix, "--", "-")}-${replace(replace(replace(var.type, "(", ""), ")", ""), "--", "-")}-subnet"
  ip_cidr_range = var.network_cidr
  private_ip_google_access = var.private_ip_google_access
  region = var.region
  network = google_compute_network.network[count.index].id
  stack_type = var.ip_stack_type
  ipv6_access_type = var.ip_stack_type != "IPV4_ONLY" ? var.ipv6_access_type : null
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