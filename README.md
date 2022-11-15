# argocd kind install

a simple project to spin up a kind cluster and deploy a argocd.

## usage

kind, jq and yq are required on your local machine.

```shell
brew install jq yq kind
```

> **be warned** the state contains your local cluster credentials!!

```shell
terraform init
terraform apply --auto-approve --var-file=multicluster.tfvars
```

### destroy

``` shell
terraform destroy --auto-approve --var-file=multicluster.tfvars
```

all required connection commands will be displayed at the end of the apply command.

### kind ingress

to opt-in a nginx-ingres for your controller cluster,\
add this line to your *.tfvars* file:
```shell
enable_ingress = true
```

add **argocd.local** and **traefik.local** to your **host** file.


## blue-green

### install kubectl plugin for argo rollouts

```shell
brew install argoproj/tap/kubectl-argo-rollouts
```

in each worker cluster there is a rollout configuration.\
check https://argoproj.github.io/argo-rollouts/ for details.

you can visit the rollout dashboard in each cluster.

```shell
k argo rollouts dashboard
```

### trigger blue-green

to trigger a rollout change any configuration inside the rollout resource.

we set the image-tag to **0.2** to get a new verion of the application.\
this can be done by editing the parameters inside the argocd webinterface.

```shell
image.tag=0.2
```

or using the kubectl plugin

```shell
# worker 1
k argo rollouts set image bluegreendemoapp-0-helm-guestbook helm-guestbook=gcr.io/heptio-images/ks-guestbook-demo:0.2
```

now we can visit both versions of the application through different services.

```shell
# old service worker 1
k port-forward svc/bluegreendemoapp-0-helm-guestbook 8080:80
# new service worker 1
k port-forward svc/bluegreendemoapp-0-helm-guestbook-preview 8081:80
```

to finish the rollout, promote it

```shell
# worker 1
k argo rollouts promote bluegreendemoapp-1-helm-guestbook
# worker 2
k argo rollouts promote bluegreendemoapp-1-helm-guestbook
```

or undo the rollout.
```shell
# worker 1
k argo rollouts undo bluegreendemoapp-0-helm-guestbook
# worker 2
k argo rollouts undo bluegreendemoapp-1-helm-guestbook
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.7 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.2.2 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.7.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.14.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.2.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.2.2 |
| <a name="provider_helm.helm"></a> [helm.helm](#provider\_helm.helm) | 2.7.1 |
| <a name="provider_helm.helm-worker-1"></a> [helm.helm-worker-1](#provider\_helm.helm-worker-1) | 2.7.1 |
| <a name="provider_helm.helm-worker-2"></a> [helm.helm-worker-2](#provider\_helm.helm-worker-2) | 2.7.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_kubectl.kubectl"></a> [kubectl.kubectl](#provider\_kubectl.kubectl) | 1.14.0 |
| <a name="provider_kubernetes.kubernetes"></a> [kubernetes.kubernetes](#provider\_kubernetes.kubernetes) | 2.14.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.argorolloutWorker0](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.argorolloutWorker1](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.external-secrets](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [kubectl_manifest.argocd-application](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.argocd-applicationBlueGreen](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.argocd-project](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.cert-issuer](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.cluster-external-secret](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.external-secrets-store](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.ingressNginx](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.nginxIngressrouteArgoCD](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.remote_cluster_secret](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.test-external-secret](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.traefikCertificate](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.traefikIngressrouteArgoCD](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.traefikIngressrouteTraefikDashboard](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubernetes_namespace.ingressNginx](https://registry.terraform.io/providers/hashicorp/kubernetes/2.14.0/docs/resources/namespace) | resource |
| [kubernetes_namespace.testNamespace](https://registry.terraform.io/providers/hashicorp/kubernetes/2.14.0/docs/resources/namespace) | resource |
| [local_file.clusterconfigController](https://registry.terraform.io/providers/hashicorp/local/2.2.3/docs/resources/file) | resource |
| [local_file.clusterconfigWorker](https://registry.terraform.io/providers/hashicorp/local/2.2.3/docs/resources/file) | resource |
| [null_resource.cluster_controller](https://registry.terraform.io/providers/hashicorp/null/3.1.1/docs/resources/resource) | resource |
| [null_resource.cluster_destroy_controller](https://registry.terraform.io/providers/hashicorp/null/3.1.1/docs/resources/resource) | resource |
| [null_resource.cluster_destroy_worker](https://registry.terraform.io/providers/hashicorp/null/3.1.1/docs/resources/resource) | resource |
| [null_resource.cluster_worker](https://registry.terraform.io/providers/hashicorp/null/3.1.1/docs/resources/resource) | resource |
| [external_external.current_ip](https://registry.terraform.io/providers/hashicorp/external/2.2.2/docs/data-sources/external) | data source |
| [external_external.kube_config_client_string](https://registry.terraform.io/providers/hashicorp/external/2.2.2/docs/data-sources/external) | data source |
| [external_external.kube_config_client_string_worker](https://registry.terraform.io/providers/hashicorp/external/2.2.2/docs/data-sources/external) | data source |
| [external_external.kube_config_server_string](https://registry.terraform.io/providers/hashicorp/external/2.2.2/docs/data-sources/external) | data source |
| [external_external.kube_config_server_string_worker](https://registry.terraform.io/providers/hashicorp/external/2.2.2/docs/data-sources/external) | data source |
| [kubectl_file_documents.argoAppFile](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.argoAppFileBlueGreen](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.argoProjectFile](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.clusterConfigControllerFile](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.clusterConfigWorkerFile](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.clusterSecret](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.clusterSecretStore](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.nginxIngressrouteFileArgoCD](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.traefikIngressrouteFileArgoCD](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.traefikIngressrouteFileDashboard](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/file_documents) | data source |
| [kubectl_path_documents.ingressFilesNginx](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/data-sources/path_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argo_ingress_host"></a> [argo\_ingress\_host](#input\_argo\_ingress\_host) | the host used argocd | `string` | `"argocd.local"` | no |
| <a name="input_blue_green_namespace_name"></a> [blue\_green\_namespace\_name](#input\_blue\_green\_namespace\_name) | another namespace to test in | `string` | `"blue-green"` | no |
| <a name="input_cluster_worker_count"></a> [cluster\_worker\_count](#input\_cluster\_worker\_count) | the number of additional clusters | `number` | `1` | no |
| <a name="input_enable_argocd"></a> [enable\_argocd](#input\_enable\_argocd) | enable argocd | `bool` | `true` | no |
| <a name="input_enable_blue_green_app"></a> [enable\_blue\_green\_app](#input\_enable\_blue\_green\_app) | enable the blue-green demo app | `bool` | `false` | no |
| <a name="input_enable_externalsecrets"></a> [enable\_externalsecrets](#input\_enable\_externalsecrets) | enable external-secrets operator | `bool` | `false` | no |
| <a name="input_enable_ingress"></a> [enable\_ingress](#input\_enable\_ingress) | enable ingress | `bool` | `false` | no |
| <a name="input_enable_multicluster"></a> [enable\_multicluster](#input\_enable\_multicluster) | enable a multicluster setup | `bool` | `false` | no |
| <a name="input_ingress_type"></a> [ingress\_type](#input\_ingress\_type) | type of ingress, possible values 'nginx', 'traefik' | `string` | `"nginx"` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | a namespace to test in | `string` | `"test"` | no |
| <a name="input_traefik_ingress_host"></a> [traefik\_ingress\_host](#input\_traefik\_ingress\_host) | the host used for traefik | `string` | `"traefik.local"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argo-default-admin-account"></a> [argo-default-admin-account](#output\_argo-default-admin-account) | the default argo-cd admin account |
| <a name="output_argo-default-secret-command"></a> [argo-default-secret-command](#output\_argo-default-secret-command) | the command to get the initial argo-cd admin token |
| <a name="output_argo-port-forward-command"></a> [argo-port-forward-command](#output\_argo-port-forward-command) | the port forward command for the argo-cd server, so you can login |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
