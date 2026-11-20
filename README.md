![renovate workflow](https://github.com/steled/homelab-terraform/actions/workflows/renovate.yaml/badge.svg) ![terraform workflow](https://github.com/steled/homelab-terraform/actions/workflows/terraform.yaml/badge.svg)

# homeserver-terraform

Repository for HomeServer install/config via Terraform

source: https://github.com/mrsauravsahu/kube-homelab/tree/main

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
