output "management_name" {
  value = var.management_name
}
output "configuration_template_name" {
  value = var.configuration_template_name
}
output "instance_template_name" {
  value = google_compute_instance_template.instance_template.name
}
output "instance_group_manager_name" {
  value = google_compute_region_instance_group_manager.instance_group_manager.name
}
output "autoscaler_name" {
  value = google_compute_region_autoscaler.autoscaler.name
}
output "security_policy_id" {
  value = google_compute_network_firewall_policy.consumer_policy.id
}
output "intercept_endpoint_group_id" {
  value = google_network_security_intercept_endpoint_group.network_security_intercept_endpoint_group.id
  description = "The ID of the intercept endpoint group."
}
