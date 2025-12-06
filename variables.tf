variable "cert_manager_email" {
  type        = string
  description = "Email for cert-mnanager"
}

variable "cilium_cidr" {
  type        = string
  description = "CIDR range for Cilium loadbalancer IP pool"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token for DNS settings"
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

variable "shared_gateway_ip_address" {
  type        = string
  description = "IP address of shared gateway"
}

variable "argocd_domain_prd" {
  type        = string
  description = "Domain for Argo CD ingress prd"
}

variable "argocd_env_prd" {
  type        = string
  description = "Environment for Argo CD prd"
}

variable "argocd_accounts_steled_password" {
  type        = string
  description = "Password for Argo CD user steled"
}

variable "argocd_apps_sshPrivateKey" {
  type        = string
  description = "SSH private key for argocd-apps repository"
}

variable "telegram_bot_token" {
  type        = string
  description = "Bot token for Telegram"
}
