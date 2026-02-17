resource "google_compute_address" "internal_ip" {
  count        = length(var.intercept_deployment_zones) == 0 ? 1 : 0
  name         = "${var.prefix}-ilb-ip"
  project      = var.project
  region       = var.region
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
}

# IPv6 address for dual stack deployments (only for regional, not zonal)
resource "google_compute_address" "internal_ipv6" {
  count        = var.ip_stack_type == "IPV4_IPV6" && length(var.intercept_deployment_zones) == 0 ? 1 : 0
  name         = "${var.prefix}-ilb-ipv6"
  project      = var.project
  region       = var.region
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
  ip_version   = "IPV6"
}

# Health check - TCP 8117 for IPv4-only, HTTPS 443 for dual stack
resource "google_compute_health_check" "health_check" {
  name    = "${var.prefix}-ilb-health-check"
  project = var.project
  
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
  name                  = "${var.prefix}-ilb-backend-service"
  project               = var.project
  protocol              = var.protocol
  health_checks         = [google_compute_health_check.health_check.id]
  region                = var.region
  network               = var.network
  connection_draining_timeout_sec = var.connection_draining_timeout
  backend  {
    group          = var.instance_group
    balancing_mode = "CONNECTION"
  }
}

# Regional IPv4 forwarding rule (for standard MIG deployments)
resource "google_compute_forwarding_rule" "forwarding_rule_regional_ipv4" {
  count                 = length(var.intercept_deployment_zones) == 0 ? 1 : 0
  name                  = "${var.prefix}-ilb-forwarding-rule-ipv4"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_version            = "IPV4"
  ip_protocol           = var.ip_protocol
  ip_address            = google_compute_address.internal_ip[0].address
  all_ports             = true  # MIG always uses all ports for next-hop routing
  subnetwork            = var.subnetwork
  backend_service       = google_compute_region_backend_service.backend_service.self_link
}

# Regional IPv6 forwarding rule for dual stack (for standard MIG deployments)
resource "google_compute_forwarding_rule" "forwarding_rule_regional_ipv6" {
  count                 = var.ip_stack_type == "IPV4_IPV6" && length(var.intercept_deployment_zones) == 0 ? 1 : 0
  name                  = "${var.prefix}-ilb-forwarding-rule-ipv6"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_version            = "IPV6"
  ip_protocol           = var.ip_protocol
  ip_address            = google_compute_address.internal_ipv6[0].address
  all_ports             = true  # MIG always uses all ports for next-hop routing
  subnetwork            = var.subnetwork
  backend_service       = google_compute_region_backend_service.backend_service.self_link
}

# Per-zone forwarding rules (for NSI deployments with intercept deployments)
resource "google_compute_forwarding_rule" "forwarding_rule_zonal" {
  for_each              = toset(var.intercept_deployment_zones)
  name                  = "${var.prefix}-ilb-forwarding-rule-${each.key}"
  project               = var.project
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_version            = "IPV4"
  ip_protocol           = var.ip_protocol
  ports                 = var.ports
  subnetwork            = var.subnetwork
  backend_service       = google_compute_region_backend_service.backend_service.self_link
}
