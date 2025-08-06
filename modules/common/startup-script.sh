#cloud-config
network:
  version: 1
  config:
  - type: bridge
    name: br1
    mtu: *eth1-mtu
    subnets:
      - address: *eth1-private
        type: static
        gateway: *default-gateway
        dns_nameservers:
        - *eth1-dns1
    bridge_interfaces:
      - eth1
kernel_parameters:
  sim:
    - sim_geneve_enabled=1
    - sim_geneve_br_dev=br1
  fw:
    - fwtls_bridge_mode_inspection=1
    - fw_geneve_enabled=1
bootcmd:
  - echo "brctl hairpin br1 eth1 on" >> /etc/rc.local
runcmd:
  - 'python3 /etc/cloud_config.py generatePassword=\"${generatePassword}\" allowUploadDownload=\"${allowUploadDownload}\" templateName=\"${templateName}\" templateVersion=\"${templateVersion}\" mgmtNIC="X${mgmtNIC}X" hasInternet=\"${hasInternet}\" config_url=\"${config_url}\" config_path=\"${config_path}\" installationType="X${installation_type}X" enableMonitoring=\"${enableMonitoring}\" shell=\"${shell}\" computed_sic_key=\"${computed_sic_key}\" sicKey=\"${sicKey}\" managementGUIClientNetwork=\"${managementGUIClientNetwork}\" primary_cluster_address_name=\"${primary_cluster_address_name}\" secondary_cluster_address_name=\"${secondary_cluster_address_name}\" managementNetwork=\"${managementNetwork}\" numAdditionalNICs=\"${numAdditionalNICs}\" smart1CloudToken="X${smart_1_cloud_token}X" name=\"${name}\" zone=\"${zoneConfig}\" region=\"${region}\" osVersion=\"${os_version}\" MaintenanceModePassword=\"${maintenance_mode_password_hash}\"'