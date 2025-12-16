output "external_network_name" {
  value = module.external_network_and_subnet.new_created_network_name
}

output "external_subnetwork_name" {
  value = module.external_network_and_subnet.new_created_subnet_name
}

output "internal_network_name" {
  value = module.internal_network_and_subnet.new_created_network_name
}

output "internal_subnetwork_name" {
  value = module.internal_network_and_subnet.new_created_subnet_name
}

output "icmp_firewall_rules" {
  value = module.icmp_firewall_rules[*].firewall_rule_name
}

output "tcp_firewall_rules" {
  value = module.tcp_firewall_rules[*].firewall_rule_name
}

output "udp_firewall_rules" {
  value = module.udp_firewall_rules[*].firewall_rule_name
}

output "sctp_firewall_rules" {
  value = module.sctp_firewall_rules[*].firewall_rule_name
}

output "esp_firewall_rules" {
  value = module.esp_firewall_rules[*].firewall_rule_name
}

output "sic_key"{
  value = module.autoscale.sic_key
}

output "management_name"{
  value = module.autoscale.configuration_template_name
}

output "instance_template_name"{
  value = module.autoscale.instance_template_name
}

output "instance_group_manager_name"{
  value = module.autoscale.instance_group_manager_name
}

output "autoscaler_name"{
  value = module.autoscale.autoscaler_name
}

output "source_image" {
  value = local.image_name
}