output "forwarding_rule" {
  description = "Map of forwarding rules by zone (for NSI). Returns empty map for regional MIG deployments."
  value = { for key, rule in google_compute_forwarding_rule.forwarding_rule_zonal : key => rule.self_link }
}

output "forwarding_rule_ip" {
  description = "The static internal IPv4 address of the forwarding rule (for regional MIG deployments only)"
  value = length(var.intercept_deployment_zones) == 0 && length(google_compute_address.internal_ip) > 0 ? google_compute_address.internal_ip[0].address : null
}

output "forwarding_rule_ipv6" {
  description = "The static internal IPv6 address of the forwarding rule (for regional MIG deployments with dual stack only)"
  value = length(google_compute_address.internal_ipv6) > 0 ? google_compute_address.internal_ipv6[0].address : null
}
