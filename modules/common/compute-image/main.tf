data "google_compute_image" "last_image" {
  project     = "checkpoint-public"
  filter      = "name eq check-point-${lower(var.os_version)}-${var.image_type}-[0-9]{3}-[0-9]{3,}-v[0-9]{8,}.*"
  most_recent = true
}