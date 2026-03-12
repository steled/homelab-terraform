module "cert_manager_cloudflare" {
  source = "git@github.com:steled/terraformmodules.git//cert-manager_cloudflare?ref=v0.33"
  # source = "../terraformmodules/cert-manager_cloudflare/"

  # renovate: datasource=github-tags depName=cert-manager packageName=cert-manager/cert-manager
  cert_manager_version     = "v1.20.0" # check version here: https://artifacthub.io/packages/helm/cert-manager/cert-manager/
  namespace                = "cert-manager"
  cloudflare_api_token     = var.cloudflare_api_token
  cert_manager_email       = var.cert_manager_email
  cert_manager_values_yaml = "${path.root}/helm-values/cert-manager.yaml"
  namespace_annotations = {
    "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
  }
  namespace_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }
}
