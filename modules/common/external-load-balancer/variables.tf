variable "project" {
  type        = string
  description = "Personal project id. The project indicates the default GCP project all of your resources will be created in."
  default     = "chkp-tf-project"
}

variable "prefix" {
  type        = string
  description = "Resources name prefix"
  default     = "chkp-tf-autoscale"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "ip_protocol" {
  description = "The IP protocol to which this rule applies. For protocol forwarding, valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3_DEFAULT."
  default     = "TCP"
  type        = string
}

variable "ports" {
  description = "Which port numbers are forwarded to the backends. If empty, all ports are forwarded."
  default     = []
  type        = list(string)
}

variable "protocol" {
  description = "The protocol used by the backend service. Valid values are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED"
  default     = "TCP"
  type        = string
}

variable "instance_group" {
  description = "The self_link of the instance group"
  type        = string
}

variable "session_affinity" {
  description = "Session affinity option. Valid values are NONE, CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO"
  default     = "CLIENT_IP_PORT_PROTO"
  type        = string
}

variable "connection_draining_timeout" {
  type = number
  description = "The time, in seconds, that the load balancer waits for active connections to complete before fully removing an instance from the backend group. The default value is 300 seconds."
  default = 300
}

variable "ip_stack_type" {
  description = "The stack type for the networks (IPV4_ONLY, IPV4_IPV6)"
  type        = string
  default     = "IPV4_ONLY"
}

variable "subnetwork" {
  description = "The subnetwork for IPv6 forwarding rule (required for dual stack)"
  type        = string
  default     = ""
}

