locals{
    custom_image = var.source_image != "" && var.source_image != "latest" ? true : false

    os_version = (
        local.custom_image ? upper(regex("check-point-(r[0-9]+)", var.source_image)[0]) :
        length(regexall("^r[0-9]+$", lower(var.os_version))) > 0 ? lower(var.os_version) :
        index("error:", "Invalid OS version. Please look at the documentation for valid OS versions.")
    )

    license_regex = "check-point-${lower(local.os_version)}-.*-(byol|payg)-.*"

    license = (
        local.custom_image ? length(regexall(local.license_regex, var.source_image)) == 1 ? regex(local.license_regex, var.source_image)[0] : index("error:", "Invalid custom image license type. Allowed values are: BYOL, PAYG") :
        contains(["byol", "payg"], lower(var.license)) ? lower(var.license) : index("error:", "Invalid license type. Allowed values are: BYOL, PAYG")
    )

    create_mgmt_network_condition = var.mgmt_network_cidr == "" ? false : true
    create_security_network_condition = var.security_network_cidr == "" ? false : true
    mgmt_icmp_traffic_condition = length(var.mgmt_network_icmp_traffic) == 0 ? false : true
    mgmt_tcp_traffic_condition = length(var.mgmt_network_tcp_traffic) == 0 ? false : true
    mgmt_udp_traffic_condition = length(var.mgmt_network_udp_traffic) == 0 ? false : true
    mgmt_sctp_traffic_condition = length(var.mgmt_network_sctp_traffic) == 0 ? false : true
    mgmt_esp_traffic_condition = length(var.mgmt_network_esp_traffic) == 0 ? false : true
}