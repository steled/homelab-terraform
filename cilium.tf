# resource "kubectl_manifest" "ciliumloadbalancerippool" {
#   yaml_body = <<YAML
# apiVersion: cilium.io/v2alpha1
# kind: CiliumLoadBalancerIPPool
# metadata:
#   name: "blue-pool"
# spec:
#   allowFirstLastIPs: "No"
#   blocks:
#   - cidr: ${var.cilium_cidr}
# YAML
# }

resource "kubernetes_manifest" "ciliumloadbalancerippool" {
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind"       = "CiliumLoadBalancerIPPool"
    "metadata" = {
      "name" = "blue-pool"
    }
    "spec" = {
      allowFirstLastIPs = "No"
      blocks = [
        {
          cidr = var.cilium_cidr
        }
      ]
    }
  }
}

# resource "kubectl_manifest" "ciliuml2announcementpolicy" {
#   yaml_body = <<YAML
# apiVersion: "cilium.io/v2alpha1"
# kind: CiliumL2AnnouncementPolicy
# metadata:
#   name: policy1
# spec:
#   interfaces:
#   - ^eth[0-9]+
#   externalIPs: true
#   loadBalancerIPs: true
# YAML
# }

resource "kubernetes_manifest" "ciliuml2announcementpolicy" {
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind"       = "CiliumL2AnnouncementPolicy"
    "metadata" = {
      "name" = "policy1"
    }
    "spec" = {
      externalIPs = true
      interfaces = [
        "^eth[0-9]+"
      ]
      loadBalancerIPs = true
    }
  }
}

# resource "kubectl_manifest" "httproute" {
#   yaml_body = <<YAML
# apiVersion: gateway.networking.k8s.io/v1
# kind: HTTPRoute
# metadata:
#   name: hubble-ui
#   namespace: kube-system
# spec:
#   hostnames:
#   - hubble-ui.steled.org
#   parentRefs:
#   - group: gateway.networking.k8s.io
#     kind: Gateway
#     name: shared-gateway
#     namespace: kube-system
#   rules:
#   - backendRefs:
#     - group: ""
#       kind: Service
#       name: hubble-ui
#       port: 80
#       weight: 1
#     matches:
#     - path:
#         type: PathPrefix
#         value: /
# YAML
# }

resource "kubernetes_manifest" "httproute" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = "hubble-ui"
      "namespace" = "kube-system"
    }
    "spec" = {
      hostnames = [
        "hubble-ui.steled.org"
      ]
      parentRefs = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "Gateway"
          name      = "shared-gateway"
          namespace = "kube-system"
        }
      ]
      rules = [
        {
          backendRefs = [
            {
              group  = ""
              kind   = "Service"
              name   = "hubble-ui"
              port   = 80
              weight = 1
            }
          ]
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
        }
      ]
    }
  }
}

# resource "kubectl_manifest" "gateway" {
#   yaml_body = <<YAML
# apiVersion: gateway.networking.k8s.io/v1
# kind: Gateway
# metadata:
#   annotations:
#     cert-manager.io/cluster-issuer: cloudflare-letsencrypt-production
#   name: shared-gateway
#   namespace: kube-system
# spec:
#   addresses:
#   - type: IPAddress
#     value: ${var.shared_gateway_ip_address}
#   gatewayClassName: cilium
#   listeners:
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: gitops.${var.domain_prd}
#     name: shared-argocd-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: argocd-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: alert.${var.domain_prd}
#     name: shared-alertmanager-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: alertmanager-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: ddns.${var.domain_prd}
#     name: shared-fritzbox-cloudflare-dyndns-chart-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: fritzbox-cloudflare-dyndns-chart-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: monitoring.${var.domain_prd}
#     name: shared-grafana-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: grafana-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: hassio.${var.domain_prd}
#     name: shared-hassio-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: hassio-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: hubble-ui.${var.domain_prd}
#     name: shared-hubble-ui-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: hubble-ui-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: jelly.${var.domain_prd}
#     name: shared-jellyfin-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: jellyfin-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: volume.${var.domain_prd}
#     name: shared-longhorn-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: longhorn-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: s3.${var.domain_prd}
#     name: shared-minio-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: minio-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: console.s3.${var.domain_prd}
#     name: shared-minio-console-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: minio-console-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: next.${var.domain_prd}
#     name: shared-nextcloud-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: nextcloud-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: vmagent.${var.domain_prd}
#     name: shared-vmagent-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: vmagent-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: vmalert.${var.domain_prd}
#     name: shared-vmalert-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: vmalert-tls-secret
#       mode: Terminate
#   - allowedRoutes:
#       namespaces:
#         from: Selector
#         selector:
#           matchLabels:
#             shared-gateway-access: "true"
#     hostname: vmsingle.${var.domain_prd}
#     name: shared-vmsingle-https-terminate
#     port: 443
#     protocol: HTTPS
#     tls:
#       certificateRefs:
#         - name: vmsingle-tls-secret
#       mode: Terminate
# YAML
# }

resource "kubernetes_manifest" "gateway" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "Gateway"
    "metadata" = {
      "annotations" = {
        "cert-manager.io/cluster-issuer" = "cloudflare-letsencrypt-production"
      }
      "name"      = "shared-gateway"
      "namespace" = "kube-system"
    }
    "spec" = {
      "addresses" = [
        {
          "type"  = "IPAddress"
          "value" = var.shared_gateway_ip_address
        }
      ]
      "gatewayClassName" = "cilium"
      "listeners" = [
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "gitops.${var.domain_prd}"
          "name"     = "shared-argocd-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "argocd-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "alert.${var.domain_prd}"
          "name"     = "shared-alertmanager-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "alertmanager-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "ddns.${var.domain_prd}"
          "name"     = "shared-fritzbox-cloudflare-dyndns-chart-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "fritzbox-cloudflare-dyndns-chart-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "monitoring.${var.domain_prd}"
          "name"     = "shared-grafana-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "grafana-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        # {
        #   "allowedRoutes" = {
        #     "namespaces" = {
        #       "from" = "Selector"
        #       "selector" = {
        #         "matchLabels" = {
        #           "shared-gateway-access" = "true"
        #         }
        #       }
        #     }
        #   }
        #   "hostname" = "home.${var.domain_prd}"
        #   "name"     = "shared-homarr-https-terminate"
        #   "port"     = 443
        #   "protocol" = "HTTPS"
        #   "tls" = {
        #     "certificateRefs" = [
        #       {
        #         "name" = "homarr-tls-secret"
        #       }
        #     ]
        #     "mode" = "Terminate"
        #   }
        # },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "home.${var.domain_prd}"
          "name"     = "shared-homepage-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "homepage-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "hassio.${var.domain_prd}"
          "name"     = "shared-hassio-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "hassio-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "hubble-ui.${var.domain_prd}"
          "name"     = "shared-hubble-ui-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "hubble-ui-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "jelly.${var.domain_prd}"
          "name"     = "shared-jellyfin-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "jellyfin-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "volume.${var.domain_prd}"
          "name"     = "shared-longhorn-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "longhorn-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "s3.${var.domain_prd}"
          "name"     = "shared-minio-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "minio-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "console.s3.${var.domain_prd}"
          "name"     = "shared-minio-console-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "minio-console-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "next.${var.domain_prd}"
          "name"     = "shared-nextcloud-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "nextcloud-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "vmagent.${var.domain_prd}"
          "name"     = "shared-vmagent-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "vmagent-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "vmalert.${var.domain_prd}"
          "name"     = "shared-vmalert-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "vmalert-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        },
        {
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
          "hostname" = "vmsingle.${var.domain_prd}"
          "name"     = "shared-vmsingle-https-terminate"
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "certificateRefs" = [
              {
                "name" = "vmsingle-tls-secret"
              }
            ]
            "mode" = "Terminate"
          }
        }
      ]
    }
  }
}