module "argocd" {
  source = "git@github.com:steled/terraformmodules.git//argocd?ref=v0.32"
  # source = "../terraformmodules/argocd/"

  # renovate: datasource=github-tags depName=argocd packageName=argoproj/argo-helm
  argocd_version = "9.1.10" # check version here: https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml#L6
  # renovate: datasource=github-tags depName=argocd-apps packageName=argoproj/argo-helm
  argocd_apps_version       = "2.0.2" # check version here: https://github.com/argoproj/argo-helm/blob/main/charts/argocd-apps/Chart.yaml#L5
  kubernetes_namespace_name = "argocd"
  domain                    = var.argocd_domain_prd
  environment               = var.argocd_env_prd
  argocd_values_yaml        = "${path.root}/helm-values/argocd.yaml"
  argocd_apps_values_yaml   = "${path.root}/helm-values/argocd_apps.yaml"
  telegram_bot_token        = var.telegram_bot_token
  accounts_steled_password  = var.argocd_accounts_steled_password
  apps_sshPrivateKey        = var.argocd_apps_sshPrivateKey

  depends_on = [module.cert_manager_cloudflare]
}
