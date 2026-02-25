terraform {
  required_version = ">= 1.5.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.47.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.4"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/canonical-mp/v0.0.1"
  }
}