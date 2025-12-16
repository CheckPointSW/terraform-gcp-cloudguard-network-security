locals {
  # Extract just the image name from full path if provided
  # Handles both "check-point-r8120-..." and "projects/checkpoint-public/global/images/check-point-r8120-..."
  image_name_short = replace(var.image_name, "/^.*\\//", "")
  
  regex_validate_mgmt_image_name = "^check-point-${lower(var.os_version)}-[^(gw)].*[0-9]{3}-([0-9]{3,}|[a-z]+)-v[0-9]{8,}.*"
  regex_validate_gw_image_name = "^check-point-${lower(var.os_version)}-gw-.*[0-9]{3}-([0-9]{3,}|[a-z]+)-v[0-9]{8,}.*"
  regex_validate_image_name = contains(["Gateway only", "Cluster", "AutoScale", "Network Security Integration"], var.installation_type) ? local.regex_validate_gw_image_name : local.regex_validate_mgmt_image_name
  
  // Validate image name format - will trigger error if validation fails (validate short name)
  validate_image_name = length(regexall(local.regex_validate_image_name, local.image_name_short)) > 0 ? 0 : index("error:", "Variable [image_name] must be a valid Check Point image name of the correct version.")

  license_allowed_values = [
    "BYOL",
    "PAYG"
  ]

  // will fail if [var.license] is invalid:
  validate_license = contains(local.license_allowed_values, var.license) ? 0 : index("error:", "Invalid License. Allowed values are: BYOL, PAYG")

  // Validate boot_disk_type - accepts both UI format and API format
  validate_boot_disk_type = contains([
    "SSD Persistent Disk", "pd-ssd",
    "Standard Persistent Disk", "pd-standard"
  ], var.boot_disk_type) ? 0 : index("error:", "Invalid boot disk type. Allowed values are: SSD Persistent Disk (pd-ssd), Standard Persistent Disk (pd-standard)")

  regex_valid_admin_SSH_key = "^(^$|ssh-(rsa|ed25519) AAAA[0-9A-Za-z+/]+[=]{0,3})"
  
  // Validate SSH key format - will trigger error if validation fails (supports RSA and ED25519)
  validate_admin_SSH_key = length(regexall(local.regex_valid_admin_SSH_key, var.admin_SSH_key)) > 0 ? 0 : index("error:", "Please enter a valid SSH public key (ssh-rsa or ssh-ed25519) or leave empty")
  
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"
  ]

  // Validate admin shell - will trigger error if validation fails
  validate_admin_shell = contains(local.admin_shell_allowed_values, var.admin_shell) ? 0 : index("error:", "Invalid admin shell. Allowed values are: /etc/cli.sh, /bin/bash, /bin/csh, /bin/tcsh")

  external_ip_allowed_values = [
    "static",
    "ephemeral",
    "none"
  ]

  // Will fail if var.externalIP is invalid
  validate_external_ip = contains(local.external_ip_allowed_values, var.externalIP) ? 0 : index("error:", "Invalid external IP type. Allowed values are: static, ephemeral, none")
}