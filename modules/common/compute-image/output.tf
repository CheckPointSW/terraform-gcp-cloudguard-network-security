output "image" {
  value = data.google_compute_image.last_image.name
  description = "The name of the Check Point image to be used for the deployment. This is derived from the most recent image matching the specified OS version and image type."
}
