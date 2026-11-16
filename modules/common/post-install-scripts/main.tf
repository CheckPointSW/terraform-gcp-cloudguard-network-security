locals {
  local_script_paths = [
    for script in var.post_install_script_paths : pathexpand(
      startswith(script, "/") || startswith(script, "~") || startswith(script, "\\\\") || can(regex("^[A-Za-z]:[/\\\\]", script))
      ? script : "${path.root}/${script}"
    ) if try(length(trimspace(script)) > 0 && !can(regex("^[A-Za-z][A-Za-z0-9+.-]*://", trimspace(script))), false)
  ]
  script_contents = concat(
    [for content in var.post_install_script_contents : base64encode(content) if content != null],
    [for script in local.local_script_paths : filebase64(script)]
  )
  wrapper_content = templatefile("${path.module}/run-post-install-scripts.sh.tftpl", {
    script_count                = length(local.script_contents)
    post_install_script_timeout = var.post_install_script_timeout
  })
  write_files = length(local.script_contents) == 0 ? "" : templatefile("${path.module}/write-files.yaml.tftpl", {
    wrapper_content = base64encode(local.wrapper_content)
    script_contents = local.script_contents
  })
  runcmd = length(local.script_contents) == 0 ? "" : "  - '/var/tmp/post_install_scripts/run-post-install-scripts.sh'\n"
}

locals {
  # Leave room for the existing startup configuration.
  startup_metadata_limit_bytes  = 256 * 1024
  startup_reserved_bytes        = 56 * 1024
  post_install_size_limit_bytes = local.startup_metadata_limit_bytes - local.startup_reserved_bytes
  post_install_payload          = length(local.script_contents) == 0 ? "" : "write_files:\n${local.write_files}\n${local.runcmd}"
  post_install_payload_bytes    = nonsensitive(length(sensitive(local.post_install_payload)))
  post_install_within_budget    = local.post_install_payload_bytes <= local.post_install_size_limit_bytes
  post_install_size_error       = "Post-install scripts render to ${local.post_install_payload_bytes} bytes, exceeding the ${local.post_install_size_limit_bytes}-byte (${local.post_install_size_limit_bytes / 1024} KiB) budget. GCP permits ${local.startup_metadata_limit_bytes / 1024} KiB; ${local.startup_reserved_bytes / 1024} KiB is reserved for the existing startup configuration. Reduce the combined script contents."
}
