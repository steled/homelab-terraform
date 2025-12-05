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
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.1.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 2.1.3 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | git@github.com:steled/terraformmodules.git//argocd | v0.29 |
| <a name="module_cert_manager_cloudflare"></a> [cert\_manager\_cloudflare](#module\_cert\_manager\_cloudflare) | git@github.com:steled/terraformmodules.git//cert-manager_cloudflare | v0.29 |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.ciliuml2announcementpolicy](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.ciliumloadbalancerippool](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [terraform_data.files](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_accounts_steled_password"></a> [argocd\_accounts\_steled\_password](#input\_argocd\_accounts\_steled\_password) | Password for Argo CD user steled | `string` | n/a | yes |
| <a name="input_argocd_apps_sshPrivateKey"></a> [argocd\_apps\_sshPrivateKey](#input\_argocd\_apps\_sshPrivateKey) | SSH private key for argocd-apps repository | `string` | n/a | yes |
| <a name="input_argocd_domain_prd"></a> [argocd\_domain\_prd](#input\_argocd\_domain\_prd) | Domain for Argo CD ingress prd | `string` | n/a | yes |
| <a name="input_argocd_env_prd"></a> [argocd\_env\_prd](#input\_argocd\_env\_prd) | Environment for Argo CD prd | `string` | n/a | yes |
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | Email for cert-mnanager | `string` | n/a | yes |
| <a name="input_cilium_cidr"></a> [cilium\_cidr](#input\_cilium\_cidr) | CIDR range for Cilium loadbalancer IP pool | `string` | n/a | yes |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API token for DNS settings | `string` | n/a | yes |
| <a name="input_server"></a> [server](#input\_server) | machine which will run the control plane | <pre>object({<br/>    host        = string,<br/>    user        = string,<br/>    private_key = string,<br/>  })</pre> | n/a | yes |
| <a name="input_telegram_bot_token"></a> [telegram\_bot\_token](#input\_telegram\_bot\_token) | Bot token for Telegram | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
