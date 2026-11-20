# Bootstrap of the GitOps stack.
#
# Terraform only bootstraps the cluster (and restores it after a disaster):
#   1. Sealed Secrets keys (restored from bootstrap/sealed-secrets-keys.yaml, transcrypt-encrypted),
#      so that the sealed-secrets controller deployed by Argo CD can decrypt all SealedSecrets.
#   2. Argo CD and the argocd-apps release (projects + root-app).
# Everything else (including cert-manager and the sealed-secrets controller) is managed by Argo CD
# from the argocd-apps repository.

locals {
  # renovate: datasource=github-tags depName=argocd packageName=argoproj/argo-helm
  argocd_version = "10.18.2" # check version here: https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml#L6
  # renovate: datasource=github-tags depName=argocd-apps packageName=argoproj/argo-helm
  argocd_apps_version = "2.0.8" # check version here: https://github.com/argoproj/argo-helm/blob/main/charts/argocd-apps/Chart.yaml#L5

  sealed_secrets_keys = {
    for key in yamldecode(file("${path.root}/bootstrap/sealed-secrets-keys.yaml")).items : key.metadata.name => key
  }
}

################################################################################
# Sealed Secrets keys
################################################################################

import {
  for_each = local.sealed_secrets_keys
  to       = kubernetes_secret_v1.sealed_secrets_key[each.key]
  id       = "kube-system/${each.key}"
}

resource "kubernetes_secret_v1" "sealed_secrets_key" {
  for_each = local.sealed_secrets_keys

  metadata {
    name      = each.key
    namespace = "kube-system"
    labels    = each.value.metadata.labels
  }

  type = each.value.type
  data = { for k, v in each.value.data : k => base64decode(v) }

  lifecycle {
    # the keys must never be removed by Terraform, otherwise all SealedSecrets become undecryptable
    prevent_destroy = true
    # set by the controller when it generates a key, not relevant for restoring
    ignore_changes = [metadata[0].generate_name]
  }
}

################################################################################
# Argo CD
################################################################################

moved {
  from = module.argocd.kubernetes_namespace_v1.argocd
  to   = kubernetes_namespace_v1.argocd
}

moved {
  from = module.argocd.helm_release.argocd
  to   = helm_release.argocd
}

moved {
  from = module.argocd.helm_release.argocd-apps
  to   = helm_release.argocd_apps
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "istio.io/dataplane-mode" = "ambient"
      "shared-gateway-access"   = "true"
    }
  }
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = local.argocd_version

  values = [sensitive(templatefile("${path.root}/helm-values/argocd.yaml", {
    environment              = var.argocd_env_prd
    domain                   = var.argocd_domain_prd
    telegram_bot_token       = var.telegram_bot_token
    accounts_steled_password = var.argocd_accounts_steled_password
    apps_sshPrivateKey       = var.argocd_apps_sshPrivateKey
  }))]

  depends_on = [kubernetes_secret_v1.sealed_secrets_key]
}

resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = local.argocd_apps_version

  values = [sensitive(file("${path.root}/helm-values/argocd_apps.yaml"))]

  depends_on = [helm_release.argocd]
}

################################################################################
# cert-manager: managed by Argo CD (argocd-apps: helm-cert-manager)
################################################################################

removed {
  from = module.cert_manager_cloudflare

  lifecycle {
    destroy = false
  }
}
