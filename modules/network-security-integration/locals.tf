locals{
    create_mgmt_network_condition = var.mgmt_network_cidr == "" ? false : true
    create_security_network_condition = var.security_network_cidr == "" ? false : true
    create_service_network_condition = var.service_network_cidr == "" ? false : true
    ICMP_traffic_condition = length(var.ICMP_traffic) == 0 ? false : true
    TCP_traffic_condition = length(var.TCP_traffic) == 0 ? false : true
    UDP_traffic_condition = length(var.UDP_traffic) == 0 ? false : true
    SCTP_traffic_condition = length(var.SCTP_traffic) == 0 ? false : true
    ESP_traffic_condition = length(var.ESP_traffic) == 0 ? false : true
}