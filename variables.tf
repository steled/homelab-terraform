variable "cilium_cidr" {
  type        = string
  description = "CIDR range for Cilium loadbalancer IP pool"
}

variable "domain_prd" {
  type        = string
  description = "Domain for applications"
}

variable "server" {
  description = "machine which will run the control plane"
  type = object({
    host        = string,
    user        = string,
    private_key = string,
  })
}

variable "shared_cilium_gateway_ip_address" {
  type        = string
  description = "IP address of cilium shared gateway"
}

variable "shared_istio_gateway_ip_address" {
  type        = string
  description = "IP address of istio shared gateway"
}

variable "argocd_apps_transcrypt_password" {
  type        = string
  description = "transcrypt password of the argocd-apps repository (used by the argocd-transcrypt-plugin in the repo-server)"
  sensitive   = true
}

variable "argocd_apps_repo_path" {
  type        = string
  description = "Path to the local (transcrypt-decrypted) checkout of the argocd-apps repository, relative to this repository"
  default     = "../argocd-apps"
}
