# create a test argo-cd project
# this is a logical group of argo applications
data "kubectl_file_documents" "argoProjectFile" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  content = templatefile("${path.module}/templates/argoproject.tftpl", {
    name                 = "test-project-${count.index}"
    destinationServer    = data.external.kube_config_server_string_worker[count.index].result.server
    destinationNamespace = var.namespace_name
  })
}

resource "kubectl_manifest" "argocd-project" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.argoProjectFile[count.index].documents[0]

  depends_on = [helm_release.argocd]
}

# install a demo app via argocd
# since this is a argocd CRD we use kubectl apply for this
data "kubectl_file_documents" "argoAppFile" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  content = templatefile("${path.module}/templates/argoapp.tftpl", {
    name                 = "demoapp-${count.index}"
    project              = "test-project-${count.index}"
    destinationServer    = data.external.kube_config_server_string_worker[count.index].result.server
    destinationNamespace = "test"
    path                 = "helm-guestbook"
  })
}

resource "kubectl_manifest" "argocd-application" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.argoAppFile[count.index].documents[0]

  depends_on = [helm_release.argocd, kubectl_manifest.argocd-project]
}

# install a demo secret store for externl-secrets
resource "kubectl_manifest" "external-secrets-store" {
  count = var.enable_externalsecrets ? 1 : 0

  provider = kubectl.kubectl

  yaml_body          = file("${path.module}/customresources/secretstore.yaml")
  override_namespace = var.namespace_name

  depends_on = [helm_release.external-secrets]
}

# install a demo external-secret
resource "kubectl_manifest" "test-external-secret" {
  count = var.enable_externalsecrets ? 1 : 0

  provider = kubectl.kubectl

  yaml_body          = file("${path.module}/customresources/externalsecret.yaml")
  override_namespace = var.namespace_name

  depends_on = [helm_release.external-secrets]
}


# add a argocd cluster configuration
# this add a remote cluster to argocd
data "kubectl_file_documents" "clusterSecretStore" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  content = templatefile("${path.module}/templates/secretstore_clusters.tftpl", {
    name     = "cluster-${count.index}"
    server   = data.external.kube_config_server_string_worker[count.index].result.server
    caData   = data.external.kube_config_server_string_worker[count.index].result.certificate-authority-data
    keyData  = data.external.kube_config_client_string_worker[count.index].result.client-key-data
    certData = data.external.kube_config_client_string_worker[count.index].result.client-certificate-data
  })
}

resource "kubectl_manifest" "remote_cluster_secret" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.clusterSecretStore[count.index].documents[0]

  depends_on = [helm_release.external-secrets]
}

data "kubectl_file_documents" "clusterSecret" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  content = templatefile("${path.module}/templates/externalsecret_clusters.tftpl", {
    name       = "cluster-secrets-${count.index}"
    storeName  = "cluster-${count.index}"
    secretName = "secret-cluster-${count.index}"
  })
}

resource "kubectl_manifest" "cluster-external-secret" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.clusterSecret[count.index].documents[0]

  depends_on = [helm_release.external-secrets]
}


# install nginx ingress for kind
resource "kubernetes_namespace" "ingressNginx" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "nginx") ? 1 : 0

  provider = kubernetes.kubernetes

  metadata {
    annotations = {
      name = "ingress-nginx"
    }

    name = "ingress-nginx"
  }
}

data "kubectl_path_documents" "ingressFilesNginx" {
  pattern = "./customresources/ingress/nginx/*.yaml"
}

resource "kubectl_manifest" "ingressNginx" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "nginx") ? length(data.kubectl_path_documents.ingressFilesNginx.documents) : 0

  provider = kubectl.kubectl

  yaml_body = element(data.kubectl_path_documents.ingressFilesNginx.documents, count.index)

  depends_on = [helm_release.argocd, kubernetes_namespace.ingressNginx]
}

data "kubectl_file_documents" "nginxIngressrouteFileArgoCD" {
  content = templatefile("${path.module}/templates/ingress/nginx/argo.tftpl", {
    ingress_host = var.argo_ingress_host
  })
}

resource "kubectl_manifest" "nginxIngressrouteArgoCD" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "nginx") ? 1 : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.nginxIngressrouteFileArgoCD.documents[0]

  depends_on = [helm_release.argocd, kubectl_manifest.ingressNginx]
}

# install traefik ingressroutes and certificate for tls
data "kubectl_file_documents" "traefikIngressrouteFileDashboard" {
  content = templatefile("${path.module}/templates/ingress/traefik/dashboard.tftpl", {
    ingress_host = var.traefik_ingress_host
  })
}

resource "kubectl_manifest" "traefikIngressrouteTraefikDashboard" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "traefik") ? 1 : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.traefikIngressrouteFileDashboard.documents[0]

  depends_on = [helm_release.traefik]
}

data "kubectl_file_documents" "traefikIngressrouteFileArgoCD" {
  content = templatefile("${path.module}/templates/ingress/traefik/argo.tftpl", {
    ingress_host = var.argo_ingress_host
  })
}

resource "kubectl_manifest" "traefikIngressrouteArgoCD" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "traefik") ? 1 : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.traefikIngressrouteFileArgoCD.documents[0]

  depends_on = [helm_release.traefik]
}

resource "kubectl_manifest" "traefikCertificate" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "traefik") ? 1 : 0

  provider = kubectl.kubectl

  yaml_body = file("${path.module}/customresources/ingress/traefik/cert.yaml")

  depends_on = [helm_release.cert-manager]
}

# install a Clusterissuer for selfsigned certificates
resource "kubectl_manifest" "cert-issuer" {
  count = var.enable_ingress == true ? 1 : 0

  provider = kubectl.kubectl

  yaml_body = file("${path.module}/customresources/certissuer.yaml")

  depends_on = [helm_release.argocd, helm_release.cert-manager]
}

# blue green setup
data "kubectl_file_documents" "argoAppFileBlueGreen" {
  count = var.enable_blue_green_app == true ? var.cluster_worker_count : 0

  content = templatefile("${path.module}/templates/argoapp.tftpl", {
    name                 = "bluegreendemoapp-${count.index}"
    project              = "default"
    destinationServer    = data.external.kube_config_server_string_worker[count.index].result.server
    destinationNamespace = var.blue_green_namespace_name
    path                 = "helm-blue-green"
  })
}

resource "kubectl_manifest" "argocd-applicationBlueGreen" {
  count = var.enable_blue_green_app == true ? var.cluster_worker_count : 0

  provider = kubectl.kubectl

  yaml_body = data.kubectl_file_documents.argoAppFileBlueGreen[count.index].documents[0]

  depends_on = [helm_release.argocd, kubectl_manifest.argocd-project]
}
