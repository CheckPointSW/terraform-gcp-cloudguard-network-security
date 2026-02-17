resource "google_compute_address" "external_ip" {
  name         = "${var.prefix}-elb-ip"
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
}

# Health check - TCP 8117 for IPv4-only, HTTPS 443 for dual stack
resource "google_compute_region_health_check" "health_check" {
  name    = "${var.prefix}-elb-health-check"
  project = var.project
  region  = var.region
  
  dynamic "tcp_health_check" {
    for_each = var.ip_stack_type == "IPV4_ONLY" ? [1] : []
    content {
      port = 8117
    }
  }
  
  dynamic "https_health_check" {
    for_each = var.ip_stack_type == "IPV4_IPV6" ? [1] : []
    content {
      port = 443
    }
  }
}

resource "google_compute_region_backend_service" "backend_service" {
  name                  = "${var.prefix}-elb-backend-service"
  project               = var.project
  protocol              = var.protocol
  health_checks         = [google_compute_region_health_check.health_check.id]
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = var.session_affinity
  connection_draining_timeout_sec = var.connection_draining_timeout
  backend {
    group = var.instance_group
    balancing_mode = "CONNECTION"
  }
}

# IPv4 forwarding rule
resource "google_compute_forwarding_rule" "forwarding_rule_ipv4" {
  name                  = "${var.prefix}-elb-forwarding-rule-ipv4"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_version            = "IPV4"
  ip_protocol           = var.ip_protocol
  ip_address            = google_compute_address.external_ip.address
  ports                 = var.ports
  backend_service       = google_compute_region_backend_service.backend_service.self_link
}

# IPv6 forwarding rule for dual stack
# IPv6 address is auto-allocated from the subnet's IPv6 range (no separate address resource needed)
resource "google_compute_forwarding_rule" "forwarding_rule_ipv6" {
  count                 = var.ip_stack_type == "IPV4_IPV6" ? 1 : 0
  name                  = "${var.prefix}-elb-forwarding-rule-ipv6"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_version            = "IPV6"
  ip_protocol           = var.ip_protocol
  ports                 = var.ports
  subnetwork            = var.subnetwork
  backend_service       = google_compute_region_backend_service.backend_service.self_link
  # No ip_address specified - GCP will auto-allocate from the subnet's IPv6 range
}

