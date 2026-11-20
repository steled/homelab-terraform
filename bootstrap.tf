# Bootstrap of the GitOps stack.
#
# Terraform only bootstraps the cluster (and restores it after a disaster):
#   1. Sealed Secrets keys (restored from bootstrap/sealed-secrets-keys.yaml, transcrypt-encrypted),
#      so that the sealed-secrets controller deployed by Argo CD can decrypt all SealedSecrets.
#   2. The transcrypt password for the argocd-apps repository (argocd-transcrypt-plugin in the repo-server).
#   3. Argo CD and the argocd-apps release (projects + root-app).
# Everything else (including cert-manager and the sealed-secrets controller) is managed by Argo CD
# from the argocd-apps repository.
#
# Versions and values of Argo CD are read from a local checkout of argocd-apps (single source of truth,
# updated by Renovate there). The checkout must be decrypted with transcrypt (values-private.yaml).
#
# After the bootstrap Argo CD manages itself (argocd-apps: helm-argocd, helm-argocd-apps), therefore the
# helm releases ignore all changes: updates happen via git in argocd-apps, not via tofu apply.
# Broken Argo CD after an update: revert in argocd-apps and run bin/argocd-recover.sh (see README).

locals {
  argocd_apps_repo   = "${path.root}/${var.argocd_apps_repo_path}"
  argocd_apps_values = yamldecode(file("${local.argocd_apps_repo}/apps/values.yaml"))

  argocd_version            = local.argocd_apps_values.argocd.version
  transcrypt_plugin_version = local.argocd_apps_values.argocd.transcryptPlugin.version
  argocd_apps_version       = local.argocd_apps_values.argocdApps.version

  argocd_values_yaml         = file("${local.argocd_apps_repo}/charts/argocd/values.yaml")
  argocd_private_values_yaml = file("${local.argocd_apps_repo}/charts/argocd/values-private.yaml")

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

data "kubernetes_resources" "sealed_secrets_keys" {
  api_version    = "v1"
  kind           = "Secret"
  namespace      = "kube-system"
  label_selector = "sealedsecrets.bitnami.com/sealed-secrets-key"
}

check "sealed_secrets_keys_backed_up" {
  assert {
    condition = alltrue([
      for o in data.kubernetes_resources.sealed_secrets_keys.objects : contains(keys(local.sealed_secrets_keys), o.metadata.name)
    ])
    error_message = "The cluster has Sealed Secrets keys that are missing in bootstrap/sealed-secrets-keys.yaml: run bin/backup-sealed-secrets-keys.sh and commit the result."
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

  values = [
    local.argocd_values_yaml,
    sensitive(local.argocd_private_values_yaml),
    yamlencode({ repoServer = { image = { tag = local.transcrypt_plugin_version } } }),
  ]

  lifecycle {
    # bootstrap only, afterwards managed by Argo CD (argocd-apps: apps/templates/helm-argocd.yaml)
    ignore_changes = all

    precondition {
      condition     = !startswith(nonsensitive(local.argocd_private_values_yaml), "U2FsdGVkX1")
      error_message = "${local.argocd_apps_repo}/charts/argocd/values-private.yaml is still encrypted: run 'transcrypt -c aes-256-cbc -p <password>' in the argocd-apps checkout (password: argocd_apps_transcrypt_password in prd.tfvars)."
    }
  }

  depends_on = [
    kubernetes_secret_v1.sealed_secrets_key,
    kubernetes_secret_v1.transcrypt_password,
  ]
}

resource "kubernetes_secret_v1" "transcrypt_password" {
  metadata {
    name      = "transcrypt-password"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }

  data = {
    cipher = "aes-256-cbc"
    # key = repository URL as sanitized by the plugin (git@github.com:steled/argocd-apps.git)
    "github.com_steled_argocd-apps" = var.argocd_apps_transcrypt_password
  }
}

resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = local.argocd_apps_version

  values = [file("${local.argocd_apps_repo}/charts/argocd-apps/values.yaml")]

  lifecycle {
    # bootstrap only, afterwards managed by Argo CD (argocd-apps: apps/templates/helm-argocd-apps.yaml)
    ignore_changes = all
  }

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
