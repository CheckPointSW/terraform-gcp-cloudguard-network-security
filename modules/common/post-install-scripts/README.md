# Post-install scripts

`post_install_script_paths` accepts local paths; URLs are rejected.
`post_install_script_contents` accepts rendered script contents.
Rendered scripts run before path scripts.
Scripts run after CloudGuard configuration and remain in `/var/tmp/post_install_scripts`.

Script contents are stored in instance metadata and Terraform state. Base64 encoding
and Terraform's `sensitive` flag do not encrypt them. **Do not include secrets or credentials.**
Fetch required secrets at runtime, for example from Secret Manager.

Encoded script budget: **200 KiB**, including the wrapper and encoding overhead.

`post_install_script_timeout` sets the per-script timeout in seconds (1-86400; default 300).
Failures are logged in `/opt/CPcge/log/boot.log`; all scripts are attempted before the wrapper returns failure.
