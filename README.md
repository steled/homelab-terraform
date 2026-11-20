![renovate workflow](https://github.com/steled/homelab-terraform/actions/workflows/renovate.yaml/badge.svg) ![terraform workflow](https://github.com/steled/homelab-terraform/actions/workflows/terraform.yaml/badge.svg)

# homeserver-terraform

Repository for HomeServer install/config via Terraform

source: https://github.com/mrsauravsahu/kube-homelab/tree/main

# GitOps bootstrap

Terraform only bootstraps the cluster ([bootstrap.tf](bootstrap.tf)). After that Argo CD manages everything from
[argocd-apps](https://github.com/steled/argocd-apps), including itself (`helm-argocd`), the AppProject and root-app
(`helm-argocd-apps`), cert-manager and the sealed-secrets controller. Updates (Renovate PRs) are merged in argocd-apps,
`tofu apply` is not needed for them.

| What | Where | Managed by |
|------|-------|------------|
| Sealed Secrets keys | `bootstrap/sealed-secrets-keys.yaml` (transcrypt) | Terraform (restore) |
| transcrypt password of argocd-apps | `prd.tfvars` (`argocd_apps_transcrypt_password`) | Terraform (`transcrypt-password` secret) |
| Argo CD version, plugin image tag, argocd-apps version | `argocd-apps/apps/values.yaml` | Renovate + Argo CD |
| Argo CD values | `argocd-apps/charts/argocd/values.yaml` + `values-private.yaml` (transcrypt) | Argo CD |
| AppProject + root-app | `argocd-apps/charts/argocd-apps/values.yaml`, root-app values in `apps/values-private.yaml` (transcrypt) | Argo CD |

Private values in argocd-apps are transcrypt-encrypted and decrypted in the repo-server by the
[argocd-transcrypt-plugin](https://github.com/steled/argocd-transcrypt-plugin).

## Bootstrap / disaster recovery

Required: the transcrypt password of this repository (password manager).

1. Clone this repository and [argocd-apps](https://github.com/steled/argocd-apps) next to each other.
2. Decrypt this repository: `transcrypt -c aes-256-cbc -p '<password>'`
3. Decrypt argocd-apps with the password from `prd.tfvars` (`argocd_apps_transcrypt_password`):
   `cd ../argocd-apps && transcrypt -c aes-256-cbc -p '<argocd_apps_transcrypt_password>'`
4. `tofu init && tofu apply -var-file=prd.tfvars`

   This restores the Sealed Secrets keys, creates the `transcrypt-password` secret and installs Argo CD and the root-app.
   Argo CD then deploys the sealed-secrets controller (which picks up the restored keys) and all other apps.
   The root-app has no automated sync: sync it once in the UI/CLI.

## Sealed Secrets keys

Key renewal is disabled (`keyrenewperiod: "0"` in argocd-apps), so the backup stays complete.

- `files/k8s-c01_backup.sh` exports all keys nightly to `/ext/backups/sealed-secrets-keys.yaml` (rsync to backup01).
- `tofu plan` warns (check `sealed_secrets_keys_backed_up`) if the cluster has keys that are missing in
  `bootstrap/sealed-secrets-keys.yaml`. Then run `bin/backup-sealed-secrets-keys.sh` and commit the result.

## Argo CD broken after an update

Argo CD cannot sync its own fix when an update broke it:

1. Revert the change in argocd-apps (`git revert`, push) and pull the local checkout.
2. Run `bin/argocd-recover.sh`: renders the argo-cd chart with version, plugin tag and values from the checkout,
   shows the diff and applies it server-side. Argo CD takes over again on its next sync.

# TF Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 3.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.argocd_apps](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.ciliuml2announcementpolicy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ciliumloadbalancerippool](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.httproute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.istio-shared-gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.sealed_secrets_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.transcrypt_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [terraform_data.files](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [kubernetes_resources.sealed_secrets_keys](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resources) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_apps_repo_path"></a> [argocd\_apps\_repo\_path](#input\_argocd\_apps\_repo\_path) | Path to the local (transcrypt-decrypted) checkout of the argocd-apps repository, relative to this repository | `string` | `"../argocd-apps"` | no |
| <a name="input_argocd_apps_transcrypt_password"></a> [argocd\_apps\_transcrypt\_password](#input\_argocd\_apps\_transcrypt\_password) | transcrypt password of the argocd-apps repository (used by the argocd-transcrypt-plugin in the repo-server) | `string` | n/a | yes |
| <a name="input_cilium_cidr"></a> [cilium\_cidr](#input\_cilium\_cidr) | CIDR range for Cilium loadbalancer IP pool | `string` | n/a | yes |
| <a name="input_domain_prd"></a> [domain\_prd](#input\_domain\_prd) | Domain for applications | `string` | n/a | yes |
| <a name="input_server"></a> [server](#input\_server) | machine which will run the control plane | <pre>object({<br/>    host        = string,<br/>    user        = string,<br/>    private_key = string,<br/>  })</pre> | n/a | yes |
| <a name="input_shared_cilium_gateway_ip_address"></a> [shared\_cilium\_gateway\_ip\_address](#input\_shared\_cilium\_gateway\_ip\_address) | IP address of cilium shared gateway | `string` | n/a | yes |
| <a name="input_shared_istio_gateway_ip_address"></a> [shared\_istio\_gateway\_ip\_address](#input\_shared\_istio\_gateway\_ip\_address) | IP address of istio shared gateway | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
