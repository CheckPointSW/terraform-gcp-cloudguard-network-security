output "mgmt_network_name" {
  value = module.mgmt_network_and_subnet.new_created_network_name
}
output "mgmt_subnetwork_name" {
  value = module.mgmt_network_and_subnet.new_created_subnet_name
}
output "security_network_name" {
  value = module.security_network_and_subnet.new_created_network_name
}
output "security_subnetwork_name" {
  value = module.security_network_and_subnet.new_created_subnet_name
}
output "security_network_gateway_address" {
  value = module.security_network_and_subnet.gateway_address
}
output "mgmt_network_icmp_firewall_rule" {
  value = module.mgmt_network_icmp_firewall_rules[*].firewall_rule_name
}
output "mgmt_network_tcp_firewall_rule" {
  value = module.mgmt_network_tcp_firewall_rules[*].firewall_rule_name
}
output "mgmt_network_udp_firewall_rule" {
  value = module.mgmt_network_udp_firewall_rules[*].firewall_rule_name
}
output "mgmt_network_sctp_firewall_rule" {
  value = module.mgmt_network_sctp_firewall_rules[*].firewall_rule_name
}
output "mgmt_network_esp_firewall_rule" {
  value = module.mgmt_network_esp_firewall_rules[*].firewall_rule_name
}
output "management_name"{
  value = module.network-security-integration.management_name
}
output "configuration_template_name"{
  value = module.network-security-integration.configuration_template_name
}
output "instance_template_name"{
  value = module.network-security-integration.instance_template_name
}
output "instance_group_manager_name"{
  value = module.network-security-integration.instance_group_manager_name
}
output "autoscaler_name"{
  value = module.network-security-integration.autoscaler_name
}
output "intercept_deployment_group_id" {
  value = module.network-security-integration.intercept_deployment_group_id
  description = "The ID of the intercept deployment group (needed for consumer setup)."
}
output "forwarding_rule" {
  value = module.network-security-integration.forwarding_rule
  description = "Map of forwarding rules by zone"
}
output "source_image" {
  value = local.image_name
}