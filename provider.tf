locals {
  kubeconfig_worker-1 = {
    host                   = try(data.external.kube_config_server_string_worker[0].result.server, null)
    cluster_ca_certificate = try(base64decode(data.external.kube_config_server_string_worker[0].result.certificate-authority-data), null)
    client_key             = try(base64decode(data.external.kube_config_client_string_worker[0].result.client-key-data), null)
    client_certificate     = try(base64decode(data.external.kube_config_client_string_worker[0].result.client-certificate-data), null)
  }
  kubeconfig_worker-2 = {
    host                   = try(data.external.kube_config_server_string_worker[1].result.server, null)
    cluster_ca_certificate = try(base64decode(data.external.kube_config_server_string_worker[1].result.certificate-authority-data), null)
    client_key             = try(base64decode(data.external.kube_config_client_string_worker[1].result.client-key-data), null)
    client_certificate     = try(base64decode(data.external.kube_config_client_string_worker[1].result.client-certificate-data), null)
  }
}

data "external" "kube_config_server_string" {
  program = ["bash", "getkubeconfig.sh"]
  query = {
    objPath = "clusters"
    cluster = "kind0"
  }
  depends_on = [null_resource.cluster_controller]
}

data "external" "kube_config_client_string" {
  program = ["bash", "getkubeconfig.sh"]
  query = {
    objPath = "users"
    cluster = "kind0"
  }
  depends_on = [null_resource.cluster_controller]
}

data "external" "kube_config_server_string_worker" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  program = ["bash", "getkubeconfig.sh"]
  query = {
    objPath = "clusters"
    cluster = "kind${count.index + 1}"
  }
  depends_on = [null_resource.cluster_worker]
}

data "external" "kube_config_client_string_worker" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  program = ["bash", "getkubeconfig.sh"]
  query = {
    objPath = "users"
    cluster = "kind${count.index + 1}"
  }
  depends_on = [null_resource.cluster_worker]
}

terraform {
  required_version = ">=1.2.7"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "null" {}
provider "kubernetes" {
  alias                  = "kubernetes"
  host                   = data.external.kube_config_server_string.result.server
  cluster_ca_certificate = base64decode(data.external.kube_config_server_string.result.certificate-authority-data)
  client_key             = base64decode(data.external.kube_config_client_string.result.client-key-data)
  client_certificate     = base64decode(data.external.kube_config_client_string.result.client-certificate-data)
}
provider "helm" {
  alias = "helm"
  kubernetes {
    host                   = data.external.kube_config_server_string.result.server
    cluster_ca_certificate = base64decode(data.external.kube_config_server_string.result.certificate-authority-data)
    client_key             = base64decode(data.external.kube_config_client_string.result.client-key-data)
    client_certificate     = base64decode(data.external.kube_config_client_string.result.client-certificate-data)
  }
}
# kubectl loads KUBECONFIG env var per default
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs#configuration
provider "kubectl" {
  alias                  = "kubectl"
  host                   = data.external.kube_config_server_string.result.server
  cluster_ca_certificate = base64decode(data.external.kube_config_server_string.result.certificate-authority-data)
  client_key             = base64decode(data.external.kube_config_client_string.result.client-key-data)
  client_certificate     = base64decode(data.external.kube_config_client_string.result.client-certificate-data)
  load_config_file       = false
}

# worker cluster context
provider "kubectl" {
  alias                  = "kubectl-worker-1"
  host                   = local.kubeconfig_worker-1.host
  cluster_ca_certificate = local.kubeconfig_worker-1.cluster_ca_certificate
  client_key             = local.kubeconfig_worker-1.client_key
  client_certificate     = local.kubeconfig_worker-1.client_certificate
  load_config_file       = false
}

provider "kubectl" {
  alias                  = "kubectl-worker-2"
  host                   = local.kubeconfig_worker-2.host
  cluster_ca_certificate = local.kubeconfig_worker-2.cluster_ca_certificate
  client_key             = local.kubeconfig_worker-2.client_key
  client_certificate     = local.kubeconfig_worker-2.client_certificate
  load_config_file       = false
}

provider "kubernetes" {
  alias                  = "kubernetes-worker-1"
  host                   = local.kubeconfig_worker-1.host
  cluster_ca_certificate = local.kubeconfig_worker-1.cluster_ca_certificate
  client_key             = local.kubeconfig_worker-1.client_key
  client_certificate     = local.kubeconfig_worker-1.client_certificate
}

provider "kubernetes" {
  alias                  = "kubernetes-worker-2"
  host                   = local.kubeconfig_worker-2.host
  cluster_ca_certificate = local.kubeconfig_worker-2.cluster_ca_certificate
  client_key             = local.kubeconfig_worker-2.client_key
  client_certificate     = local.kubeconfig_worker-2.client_certificate
}

provider "helm" {
  alias = "helm-worker-1"
  kubernetes {
    host                   = local.kubeconfig_worker-1.host
    cluster_ca_certificate = local.kubeconfig_worker-1.cluster_ca_certificate
    client_key             = local.kubeconfig_worker-1.client_key
    client_certificate     = local.kubeconfig_worker-1.client_certificate
  }
}

provider "helm" {
  alias = "helm-worker-2"
  kubernetes {
    host                   = local.kubeconfig_worker-2.host
    cluster_ca_certificate = local.kubeconfig_worker-2.cluster_ca_certificate
    client_key             = local.kubeconfig_worker-2.client_key
    client_certificate     = local.kubeconfig_worker-2.client_certificate
  }
}
