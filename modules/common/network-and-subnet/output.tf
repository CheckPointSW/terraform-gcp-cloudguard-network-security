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