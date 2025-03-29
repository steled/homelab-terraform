module "hashicorp_vault" {
  source = "git@github.com:steled/terraformmodules.git//hashicorp-vault?ref=v0.15"
  # source = "../terraformmodules/hashicorp-vault/"

  ssh_user = var.server.user
  ssh_host = var.server.host

  # renovate: datasource=github-tags depName=hashicorp-vault packageName=hashicorp/vault-helm
  hashicorp_vault_version   = "0.30.0" # check version here: https://github.com/hashicorp/vault-helm/blob/main/Chart.yaml#L6
  kubernetes_namespace_name = "hashicorp-vault"
  hashicorp_vault_domain    = var.hashicorp_vault_domain
  environment               = var.hashicorp_vault_env
  ip_address                = var.hashicorp_vault_ip_address
  values_yaml               = "${path.root}/helm-values/hashicorp-vault.yaml"

  depends_on = [module.cert_manager_cloudflare]
}
