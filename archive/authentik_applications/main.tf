terraform {
  required_version = ">=1.3.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.2.0"
    }
  }
}

provider "authentik" {
  url   = var.authentik_url
  token = var.token
  # Optionally set insecure to ignore TLS Certificates
  insecure = true
}
