locals {
  ingressHttpContainerPort  = var.ingress_type == "nginx" ? 80 : 30000
  ingressHttpsContainerPort = var.ingress_type == "nginx" ? 443 : 30001
}

data "external" "current_ip" {
  program = ["bash", "-c", "ifconfig en0 | awk '$1 == \"inet\" {print $2}' | jq -R '{\"ip\": . }'"]
}

# controller cluster setup
data "kubectl_file_documents" "clusterConfigControllerFile" {
  content = templatefile("${path.module}/templates/kindcluster.tftpl", {
    apiPort            = 9442
    httpPort           = 80
    httpsPort          = 443
    httpContainerPort  = local.ingressHttpContainerPort
    httpsContainerPort = local.ingressHttpsContainerPort
    ip                 = data.external.current_ip.result.ip
  })
}

resource "local_file" "clusterconfigController" {
  content  = data.kubectl_file_documents.clusterConfigControllerFile.documents[0]
  filename = "${path.module}/customresources/kindcluster_controller.yaml"
}

resource "null_resource" "cluster_controller" {
  provisioner "local-exec" {
    when    = create
    command = "kind create cluster --name kind0  --config customresources/kindcluster_controller.yaml"
  }

  depends_on = [local_file.clusterconfigController]
}

# worker cluster setup
data "kubectl_file_documents" "clusterConfigWorkerFile" {
  count = var.enable_multicluster ? var.cluster_worker_count : 0

  content = templatefile("${path.module}/templates/kindcluster.tftpl", {
    # tflint-ignore: terraform_deprecated_interpolation
    apiPort = "${9443 + count.index}"
    # tflint-ignore: terraform_deprecated_interpolation
    httpPort = "${8080 + count.index}"
    # tflint-ignore: terraform_deprecated_interpolation
    httpsPort          = "${8443 + count.index}"
    httpContainerPort  = 30000
    httpsContainerPort = 30001
    ip                 = data.external.current_ip.result.ip
  })
}

resource "local_file" "clusterconfigWorker" {
  count = var.enable_multicluster ? var.cluster_worker_count : 1

  content  = data.kubectl_file_documents.clusterConfigWorkerFile[count.index].documents[0]
  filename = "${path.module}/customresources/kindcluster${count.index}.yaml"
}

resource "null_resource" "cluster_worker" {
  count = var.enable_multicluster ? var.cluster_worker_count : 1

  provisioner "local-exec" {
    when    = create
    command = "kind create cluster --name kind${count.index + 1} --config customresources/kindcluster${count.index}.yaml"
  }

  depends_on = [local_file.clusterconfigWorker]
}

# destroy
resource "null_resource" "cluster_destroy_controller" {
  count = var.enable_multicluster ? var.cluster_worker_count : 1

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 30 && kind delete cluster --name kind${count.index}"
  }
}

resource "null_resource" "cluster_destroy_worker" {
  count = var.enable_multicluster ? var.cluster_worker_count : 1

  provisioner "local-exec" {
    when    = destroy
    command = "sleep ${count.index + 1}0 && kind delete cluster --name kind${count.index + 1}"
  }
}
