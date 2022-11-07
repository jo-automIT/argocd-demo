resource "kubernetes_namespace" "testNamespace" {
  provider = kubernetes.kubernetes
  metadata {
    name = var.namespace_name
  }
}
