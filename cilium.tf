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
          namespace = "istio-system"
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
