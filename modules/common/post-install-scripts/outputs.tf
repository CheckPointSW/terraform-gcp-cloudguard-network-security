output "write_files" {
  description = "Post-install YAML entries to insert under write_files."
  value       = local.write_files
  sensitive   = true

  precondition {
    condition     = local.post_install_within_budget
    error_message = local.post_install_size_error
  }
}

output "runcmd" {
  description = "Post-install YAML entries to insert at the end of runcmd."
  value       = local.runcmd
  sensitive   = true

  precondition {
    condition     = local.post_install_within_budget
    error_message = local.post_install_size_error
  }
}
