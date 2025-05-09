module "dht22" {
  source = "git@github.com:steled/terraformmodules.git//dht22?ref=modules"

  namespace   = "sdm-dht22"
  node_name   = "ubuntu-test"
  sdm_image   = "registry.gitlab.com/arm-research/smarter/smarter-device-manager:v1.20.10"
  dht22_image = "steled/dht22:0.4.0"

  depends_on = [ssh_resource.install_k3s]
}
