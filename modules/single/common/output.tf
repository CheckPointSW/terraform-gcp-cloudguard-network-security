output "external_ip" {
  value = length(google_compute_instance.gateway.network_interface[0].access_config) > 0 ? google_compute_instance.gateway.network_interface[0].access_config[0].nat_ip : null
}

output "admin_password" {
  value = var.generate_password ? [random_string.generated_password.result] : []
}
