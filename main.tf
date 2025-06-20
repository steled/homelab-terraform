provider "kubernetes" {
  config_path = "/home/steled/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "/home/steled/.kube/config"
  }
}

provider "kubectl" {
  config_path = "/home/steled/.kube/config"
}
