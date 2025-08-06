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
output "service_network_name" {
  value = module.service_network_and_subnet.new_created_network_name
}
output "service_subnetwork_name" {
  value = module.service_network_and_subnet.new_created_subnet_name
}
output "network_ICMP_firewall_rule" {
  value = module.network_ICMP_firewall_rules[*].firewall_rule_name
}
output "network_TCP_firewall_rule" {
  value = module.network_TCP_firewall_rules[*].firewall_rule_name
}
output "network_UDP_firewall_rule" {
  value = module.network_UDP_firewall_rules[*].firewall_rule_name
}
output "network_SCTP_firewall_rule" {
  value = module.network_SCTP_firewall_rules[*].firewall_rule_name
}
output "network_ESP_firewall_rule" {
  value = module.network_ESP_firewall_rules[*].firewall_rule_name
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
output "security_policy_id" {
  value = module.network-security-integration.security_policy_id
}
output "intercept_endpoint_group_id" {
  value = module.network-security-integration.intercept_endpoint_group_id
  description = "The ID of the intercept endpoint group."
}