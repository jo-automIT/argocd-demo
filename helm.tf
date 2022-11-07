# reuqired for traefik since we terminate the tls in the ingress
locals {
  valuesFileName = var.enable_ingress && var.ingress_type == "traefik" ? "argocd_insecure.values.yaml" : "argocd.values.yaml"
}

# install a default argocd (non HA)
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
resource "helm_release" "argocd" {
  count = var.enable_argocd == true ? 1 : 0

  provider = helm.helm

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argo-cd"
  create_namespace = true

  values = [
    # tflint-ignore: terraform_deprecated_interpolation
    "${file("helm/${local.valuesFileName}")}"
  ]

}

# install a external-secrets operator
# https://charts.external-secrets.io
resource "helm_release" "external-secrets" {
  count = var.enable_externalsecrets == true ? 1 : 0

  provider = helm.helm

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  # also install crds
  set {
    name  = "installCRDs"
    value = true
  }
}

# install a cert-manager
# https://github.com/cert-manager/cert-manager/tree/master/deploy/charts/cert-manager
resource "helm_release" "cert-manager" {
  count = var.enable_ingress == true ? 1 : 0

  provider = helm.helm

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  # also install crds
  set {
    name  = "installCRDs"
    value = true
  }

}

# install traefik ingress
# https://github.com/traefik/traefik-helm-chart/tree/master/traefik
resource "helm_release" "traefik" {
  count = var.enable_ingress == true && startswith(var.ingress_type, "traefik") ? 1 : 0

  provider = helm.helm

  name             = "traefik"
  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  namespace        = "traefik-system"
  create_namespace = true

  values = [
    # tflint-ignore: terraform_deprecated_interpolation
    "${file("helm/traefik.values.yaml")}"
  ]
}

# install argo-rollouts
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-rollouts
resource "helm_release" "argorolloutWorker0" {
  count = var.enable_blue_green_app == true ? 1 : 0

  provider = helm.helm-worker-1

  name             = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  namespace        = "argo-rollouts"
  create_namespace = true

  values = [
    # tflint-ignore: terraform_deprecated_interpolation
    "${file("helm/argorollouts.values.yaml")}"
  ]
}

resource "helm_release" "argorolloutWorker1" {
  count = var.enable_blue_green_app == true ? 1 : 0

  provider = helm.helm-worker-2

  name             = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  namespace        = "argo-rollouts"
  create_namespace = true

  values = [
    # tflint-ignore: terraform_deprecated_interpolation
    "${file("helm/argorollouts.values.yaml")}"
  ]
}
