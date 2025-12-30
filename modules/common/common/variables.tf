variable "installation_type" {
  type = string
  description = "Installation type"
  default = "Gateway only"
}

variable "os_version" {
  type = string
  description = "GAIA OS version"
  default = "R8120"
  validation {
    condition = contains(["R8110", "R8120" , "R82", "R8210"], var.os_version)
    error_message = "Allowed values for os_version are 'R8110' , 'R8120', 'R82', 'R8210'"
  }
}

variable "image_name" {
  type = string
  description = "The single gateway and management image name"
}

variable "license" {
  type = string
  description = "Checkpoint license (BYOL or PAYG)."
  default = "BYOL"
}

variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the template instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}

variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
}

variable "externalIP" {
  type = string
  description = "External IP address type"
  default = "static"
  validation {
    condition = contains(["static", "ephemeral", "none"], var.externalIP)
    error_message = "Invalid value for externalIP. Allowed values are 'static', 'ephemeral' or 'none'."
  }
}

variable "boot_disk_type" {
  type        = string
  description = "The boot disk type for the VM instance."
  default     = "SSD Persistent Disk"
}
