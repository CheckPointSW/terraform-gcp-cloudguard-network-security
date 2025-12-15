variable "os_version" {
  description = "The OS version of the Check Point image."
  type        = string
}

variable "image_type" {
  description = "The source image to use for the Check Point deployment. If not specified, the latest image will be used."
  type        = string
}