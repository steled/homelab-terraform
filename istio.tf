resource "kubernetes_manifest" "istio-shared-gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "shared-gateway"
      namespace = "istio-system"
      # Workaround for istio/istio#61940: on K8s 1.36 istiod fails to write this annotation
      # itself (via /status) and then never renders the gateway Deployment, so Istio
      # upgrades don't reach the gateway. Remove once an Istio release with the fix is installed.
      annotations = {
        "gateway.istio.io/controller-version" = "5"
      }
    }

    spec = {
      addresses = [
        {
          type  = "IPAddress"
          value = var.shared_istio_gateway_ip_address
        }
      ]
      gatewayClassName = "istio"
      listeners = [
        {
          allowedRoutes = {
            namespaces = {
              from = "Selector"
              selector = {
                matchLabels = {
                  shared-gateway-access = "true"
                }
              }
            }
          }
          hostname = "*.${var.domain_prd}"
          name     = "https"
          port     = 443
          protocol = "HTTPS"
          tls = {
            certificateRefs = [
              {
                kind      = "Secret"
                name      = "domain-wildcard-certificate-tls"
                namespace = "istio-system"
              }
            ]
            mode = "Terminate"
          }
        }
      ]
    }
  }
}
