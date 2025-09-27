#!/bin/bash

# define tool versions
# to check for versions use: apt-cache policy <PACKAGE>
KUBERNETS_VERSION=1.30
HELM_VERSION=3.15.1-1
TERRAFROM_VERSION=1.4.6-1

# install required packages
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common

# install kubectl
## download Google Cloud public signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$KUBERNETS_VERSION/deb/Release.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/kubernetes.gpg
# add Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETS_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## update apt package index and install kubectl
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kubectl

## add autocompletion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

# add k alias and autocompletion for alias
echo 'alias k=kubectl' >> ~/.bash_aliases
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

# install Helm
## download baltocdn public signing key
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

## add Helm apt repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

## update apt package index and install helm
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install helm=$HELM_VERSION

## add autocompletion
helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null

# install Terraform
## download HashiCorp public signing key
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

## add HashiCorp apt repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

## update apt package index and install helm
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install terraform=$TERRAFROM_VERSION

## add autocompletion
terraform -install-autocomplete | sudo tee /etc/bash_completion.d/terraform > /dev/null

# add kubectl completion
sudo sh -c 'kubectl completion bash > /etc/bash_completion.d/kubectl'
# add helm completion
sudo sh -c 'helm completion bash > /etc/bash_completion.d/helm'
# add terraform completion
sudo sh -c "echo complete -C /usr/local/bin/terraform terraform > /etc/bash_completion.d/terraform"
