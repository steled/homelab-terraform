removed {
  from = kubernetes_manifest.istio-shared-gateway

  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_manifest.istio-internal-gateway

  lifecycle {
    destroy = false
  }
}

resource "kubernetes_manifest" "hubble-ui-httproute" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = "hubble-ui"
      "namespace" = "kube-system"
    }
    "spec" = {
      hostnames = [
        "hubble-ui.${var.domain_prd}"
      ]
      parentRefs = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "Gateway"
          name      = "shared-gateway"
          namespace = "istio-system"
        },
        {
          group     = "gateway.networking.k8s.io"
          kind      = "Gateway"
          name      = "internal-gateway"
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
