output "external_ip" {
  value = google_compute_address.external_ip.address
  description = "The static external IPv4 address of the load balancer"
}

output "external_ipv6" {
  value = length(google_compute_forwarding_rule.forwarding_rule_ipv6) > 0 ? google_compute_forwarding_rule.forwarding_rule_ipv6[0].ip_address : null
  description = "The auto-allocated external IPv6 address of the load balancer (for dual stack deployments)"
}

