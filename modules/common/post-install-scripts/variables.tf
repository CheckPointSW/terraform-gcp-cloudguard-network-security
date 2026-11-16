variable "post_install_script_paths" {
  description = "Local script paths (absolute, caller-relative or home-relative)."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for script in var.post_install_script_paths : try(length(trimspace(script)) > 0 && !can(regex("^[A-Za-z][A-Za-z0-9+.-]*://", trimspace(script))), false)])
    error_message = "Post-install scripts must be non-empty local file paths; URLs and null entries are not supported."
  }
}

variable "post_install_script_contents" {
  description = "Rendered script contents run before local script paths."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for content in var.post_install_script_contents : content != null])
    error_message = "Post-install script contents must not contain null entries."
  }
}

variable "post_install_script_timeout" {
  description = "Maximum runtime per script in whole seconds (1-86400)."
  type        = number
  default     = 300
  nullable    = false

  validation {
    condition     = var.post_install_script_timeout >= 1 && var.post_install_script_timeout <= 86400 && floor(var.post_install_script_timeout) == var.post_install_script_timeout
    error_message = "post_install_script_timeout must be a whole number between 1 and 86400 seconds."
  }
}
