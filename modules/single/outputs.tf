output "network" {
  value =  module.network_and_subnet.new_created_network_name
}

output "subnetwork" {
  value = module.network_and_subnet.new_created_subnet_name
}

output "network_icmp_firewall_rules" {
  value = module.network_icmp_firewall_rules[*].firewall_rule_name
}

output "network_tcp_firewall_rules" {
  value = module.network_tcp_firewall_rules[*].firewall_rule_name
}

output "network_udp_firewall_rules" {
  value = module.network_udp_firewall_rules[*].firewall_rule_name
}

output "network_sctp_firewall_rules" {
  value = module.network_sctp_firewall_rules[*].firewall_rule_name
}

output "network_esp_firewall_rules" {
  value = module.network_esp_firewall_rules[*].firewall_rule_name
}

output "network_icmp_ipv6_firewall_rules" {
  value = module.network_icmp_ipv6_firewall_rules[*].firewall_rule_name
}

output "network_tcp_ipv6_firewall_rules" {
  value = module.network_tcp_ipv6_firewall_rules[*].firewall_rule_name
}

output "network_udp_ipv6_firewall_rules" {
  value = module.network_udp_ipv6_firewall_rules[*].firewall_rule_name
}

output "network_sctp_ipv6_firewall_rules" {
  value = module.network_sctp_ipv6_firewall_rules[*].firewall_rule_name
}

output "network_esp_ipv6_firewall_rules" {
  value = module.network_esp_ipv6_firewall_rules[*].firewall_rule_name
}

output "external_ip" {
  value = module.single.external_ip
}

output "external_ipv6" {
  value = module.single.external_ipv6
}

output "int_network1_new_created_network" {
  value = module.internal_network1_and_subnet[*].new_created_network_name
}

output "int_network1_new_created_subnet" {
  value = module.internal_network1_and_subnet[*].new_created_subnet_name
}

output "int_network2_new_created_network" {
  value = module.internal_network2_and_subnet[*].new_created_network_name
}

output "int_network2_new_created_subnet" {
  value = module.internal_network2_and_subnet[*].new_created_subnet_name
}

output "int_network3_new_created_network" {
  value = module.internal_network3_and_subnet[*].new_created_network_name
}

output "int_network3_new_created_subnet" {
  value = module.internal_network3_and_subnet[*].new_created_subnet_name
}

output "int_network4_new_created_network" {
  value = module.internal_network4_and_subnet[*].new_created_network_name
}

output "int_network4_new_created_subnet" {
  value = module.internal_network4_and_subnet[*].new_created_subnet_name
}

output "int_network5_new_created_network" {
  value = module.internal_network5_and_subnet[*].new_created_network_name
}

output "int_network5_new_created_subnet" {
  value = module.internal_network5_and_subnet[*].new_created_subnet_name
}

output "int_network6_new_created_network" {
  value = module.internal_network6_and_subnet[*].new_created_network_name
}

output "int_network6_new_created_subnet" {
  value = module.internal_network6_and_subnet[*].new_created_subnet_name
}

output "int_network7_new_created_network" {
  value = module.internal_network7_and_subnet[*].new_created_network_name
}

output "int_network7_new_created_subnet" {
  value = module.internal_network7_and_subnet[*].new_created_subnet_name
}

output "source_image" {
  value = local.image_name
}

output "admin_password" {
  value = module.single.admin_password
  description = "The auto-generated admin password (when generate_password = true)"
}

output "sic_key" {
  value = var.sic_key
  description = "The SIC key used for gateway configuration"
}