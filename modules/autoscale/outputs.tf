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

# IPv6 Firewall Rules Outputs
output "icmp_ipv6_firewall_rules" {
  value = local.icmp_ipv6_traffic_condition > 0 ? module.icmp_ipv6_firewall_rules[*].firewall_rule_name : []
}

output "tcp_ipv6_firewall_rules" {
  value = local.tcp_ipv6_traffic_condition > 0 ? module.tcp_ipv6_firewall_rules[*].firewall_rule_name : []
}

output "udp_ipv6_firewall_rules" {
  value = local.udp_ipv6_traffic_condition > 0 ? module.udp_ipv6_firewall_rules[*].firewall_rule_name : []
}

output "sctp_ipv6_firewall_rules" {
  value = local.sctp_ipv6_traffic_condition > 0 ? module.sctp_ipv6_firewall_rules[*].firewall_rule_name : []
}

output "esp_ipv6_firewall_rules" {
  value = local.esp_ipv6_traffic_condition > 0 ? module.esp_ipv6_firewall_rules[*].firewall_rule_name : []
}

output "admin_password" {
  value = var.generate_password ? module.autoscale.generated_admin_password : ""
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

output "external_network_ipv6_ula" {
  description = "IPv6 CIDR range for external network (auto-generated or specified)"
  value = var.ip_stack_type == "IPV4_IPV6" ? module.external_network_and_subnet.ipv6_range : null
}

output "internal_network_ipv6_ula" {
  description = "IPv6 CIDR range for internal network (auto-generated or specified)" 
  value = var.ip_stack_type == "IPV4_IPV6" ? module.internal_network_and_subnet.ipv6_range : null
}

output "ip_stack_type" {
  description = "The IP stack type used for this deployment (IPV4_ONLY or IPV4_IPV6)"
  value = var.ip_stack_type
}

# Load Balancer Outputs
output "external_lb_ip" {
  description = "The external IPv4 address of the external load balancer (if deployed)"
  value = var.deploy_external_lb ? module.external_load_balancer[0].external_ip : null
}

output "external_lb_ipv6" {
  description = "The external IPv6 address of the external load balancer (auto-allocated from subnet for dual stack)"
  value = var.deploy_external_lb && var.ip_stack_type == "IPV4_IPV6" ? module.external_load_balancer[0].external_ipv6 : null
}

output "internal_lb_ip" {
  description = "The internal IPv4 address of the internal load balancer (if deployed)"
  value = var.deploy_internal_lb ? module.internal_load_balancer[0].forwarding_rule_ip : null
}

output "internal_lb_ipv6" {
  description = "The internal IPv6 address of the internal load balancer (if deployed with dual stack)"
  value = var.deploy_internal_lb && var.ip_stack_type == "IPV4_IPV6" ? module.internal_load_balancer[0].forwarding_rule_ipv6 : null
}