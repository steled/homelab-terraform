module "apprise" {
  source = "git@github.com:steled/terraformmodules.git//apprise?ref=v0.15"
  # source = "../terraformmodules/apprise/"

  ssh_user = var.server.user
  ssh_host = var.server.host

  # renovate: datasource=docker depName=apprise packageName=caronc/apprise
  apprise_version           = "1.1.9" # check version here: https://registry.hub.docker.com/r/caronc/apprise/tags
  kubernetes_namespace_name = "apprise"
  # apprise_api_htpasswd_secret = var.apprise_api_htpasswd_secret
  environment = var.apprise_env_prd
  domain      = var.apprise_domain

  depends_on = [module.cert_manager_cloudflare]
}
