module "nextcloud_staging" {
  source = "git@github.com:steled/terraformmodules.git//nextcloud_staging?ref=v0.15"
  # source = "../terraformmodules/nextcloud/"

  ssh_user = var.server.user
  ssh_host = var.server.host

  # renovate: datasource=github-tags depName=nextcloud packageName=nextcloud/helm
  nextcloud_version         = "6.6.9" # get version from here: https://github.com/nextcloud/helm/blob/main/charts/nextcloud/Chart.yaml#L3
  kubernetes_namespace_name = "nextcloud-staging"
  maintenance_job_image     = "nextcloud:30.0.5-fpm" # get version from here: https://github.com/nextcloud/helm/blob/main/charts/nextcloud/Chart.yaml#L5
  nextcloud_domain          = var.nextcloud_stg_domain
  environment               = var.nextcloud_stg_env
  ip_address                = var.nextcloud_stg_ip_address
  nextcloud_admin_username  = var.nextcloud_admin_username
  nextcloud_admin_password  = var.nextcloud_admin_password
  nextcloud_proxies         = var.nextcloud_proxies
  mail_fromaddress          = var.nextcloud_stg_mail_fromaddress
  mail_domain               = var.nextcloud_mail_domain
  smtp_host                 = var.nextcloud_smtp_host
  smtp_port                 = "587"
  smtp_username             = var.nextcloud_smtp_username
  smtp_password             = var.nextcloud_smtp_password
  redis_password            = var.nextcloud_redis_password
  postgresql_username       = var.nextcloud_postgresql_username
  postgresql_admin_password = var.nextcloud_postgresql_admin_password
  postgresql_user_password  = var.nextcloud_postgresql_user_password
  postgresql_database       = var.nextcloud_postgresql_database
  values_yaml               = "${path.root}/helm-values/nextcloud-stg.yaml"

  depends_on = [module.cert_manager_cloudflare]
}
