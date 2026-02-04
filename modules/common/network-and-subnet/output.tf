output "new_created_network_link" {
  value = google_compute_network.network[*].self_link
}
output "new_created_subnet_link" {
  value = google_compute_subnetwork.new_subnetwork[*].self_link
}
output "existing_network_link" {
  value = data.google_compute_network.network_name[*].self_link
}
output "new_created_network_name" {
  value = google_compute_network.network[*].name
}
output "new_created_subnet_name" {
  value = google_compute_subnetwork.new_subnetwork[*].name
}
output "existing_network_name" {
  value = data.google_compute_network.network_name[*].name
}
output "gateway_address" {
  value = local.create_network_condition ? google_compute_subnetwork.new_subnetwork[0].gateway_address : data.google_compute_subnetwork.existing_subnetwork[0].gateway_address
}

output "ipv6_range" {
  value = local.create_network_condition && var.ip_stack_type == "IPV4_IPV6" ? (
    length(google_compute_subnetwork.new_subnetwork) > 0 ? try(google_compute_subnetwork.new_subnetwork[0].ipv6_cidr_range, "") : ""
  ) : ""
}

output "network_ipv6_ula" {
  value = local.create_network_condition && var.ip_stack_type == "IPV4_IPV6" ? (
    length(google_compute_network.network) > 0 ? try(google_compute_network.network[0].internal_ipv6_range, "") : ""
  ) : ""
}