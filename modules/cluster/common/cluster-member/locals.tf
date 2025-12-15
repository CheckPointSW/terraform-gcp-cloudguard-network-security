locals {
  disk_type_condition = (
    var.disk_type == "SSD Persistent Disk" || var.disk_type == "pd-ssd" ? "pd-ssd" :
    var.disk_type == "Standard Persistent Disk" || var.disk_type == "pd-standard" ? "pd-standard" :
    var.disk_type
  )
  admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
  deploy_with_public_ips = var.deploy_with_public_ips == true ? 1 : 0
}