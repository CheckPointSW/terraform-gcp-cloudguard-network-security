locals{
    mgmt_nic_condition = var.management_nic == "Ephemeral Public IP (eth0)" ? true : false
    mgmt_nic_ip_address_condition = local.mgmt_nic_condition ? "x-chkp-ip-address--public" : "x-chkp-ip-address--private"
    mgmt_nic_interface_condition = local.mgmt_nic_condition ? "x-chkp-management-interface--eth0" : "x-chkp-management-interface--eth1"
    network_defined_by_routes_condition = var.network_defined_by_routes ? "x-chkp-topology-eth1--internal" : ""
    network_defined_by_routes_settings_condition = var.network_defined_by_routes ? "x-chkp-topology-settings-eth1--network-defined-by-routes" : ""
    admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
    disk_type_condition = (
      var.disk_type == "SSD Persistent Disk" || var.disk_type == "pd-ssd" ? "pd-ssd" :
      var.disk_type == "Standard Persistent Disk" || var.disk_type == "pd-standard" ? "pd-standard" :
      var.disk_type
    )
}