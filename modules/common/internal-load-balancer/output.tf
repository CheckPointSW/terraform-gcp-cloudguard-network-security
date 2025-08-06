output "forwarding_rule" {
  value = { for key, rule in google_compute_forwarding_rule.forwarding_rule : key => rule.self_link }
}