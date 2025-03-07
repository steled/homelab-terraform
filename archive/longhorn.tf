module "longhorn" {
  source = "git@github.com:steled/terraformmodules.git//longhorn?ref=v0.15"
  # source = "../terraformmodules/longhorn/"

  # renovate: datasource=github-tags depName=longhorn packageName=longhorn/longhorn
  longhorn_version          = "1.8.1" # check version here: https://github.com/longhorn/longhorn/blob/master/chart/Chart.yaml#L3
  kubernetes_namespace_name = "longhorn"
  domain                    = var.longhorn_domain_prd
  environment               = var.longhorn_env_prd
  values_yaml               = "${path.root}/helm-values/longhorn.yaml"

  depends_on = [module.cert_manager_cloudflare]
}
