module "victoriametrics" {
  source = "git@github.com:steled/terraformmodules.git//victoriametrics?ref=v0.15"
  # source = "../terraformmodules/victoriametrics/"

  # renovate: datasource=docker depName=haproxy packageName=haproxy
  haproxy_version = "3.1.6-alpine" # check version here: https://hub.docker.com/_/haproxy/tags?name=alpine
  # renovate: datasource=github-tags depName=victoriametrics packageName=VictoriaMetrics/helm-charts
  victoriametrics_version   = "0.39.4" # check version here: https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-k8s-stack/Chart.yaml#L5
  kubernetes_namespace_name = "victoriametrics"
  vmsingle_domains          = var.victoriametrics_vmsingle_domains
  alertmanager_domains      = var.victoriametrics_alertmanager_domains
  vmalert_domains           = var.victoriametrics_vmalert_domains
  vmagent_domains           = var.victoriametrics_vmagent_domains
  grafana_domains           = var.victoriametrics_grafana_domains
  environment               = var.victoriametrics_env_prd
  grafana_admin_user        = var.victoriametrics_grafana_admin_user
  grafana_admin_password    = var.victoriametrics_grafana_admin_password
  grafana_client_id         = var.authentik_grafana_client_id
  grafana_client_secret     = var.authentik_grafana_client_secret
  telegram_bot_token        = var.telegram_bot_token
  telegram_chat_id          = var.telegram_chat_id
  notify_domain             = var.apprise_domain
  apprise_config_id         = var.apprise_config_id
  authentik_url             = var.authentik_url
  values_yaml               = "${path.root}/helm-values/victoriametrics.yaml"

  depends_on = [module.cert_manager_cloudflare]
}
