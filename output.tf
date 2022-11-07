output "argo-default-secret-command" {
  value       = "kubectx kind-kind0 && kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
  description = "the command to get the initial argo-cd admin token"
}
output "argo-default-admin-account" {
  value       = "admin"
  description = "the default argo-cd admin account"
}
output "argo-port-forward-command" {
  value       = "kubectx kind-kind0 && kubectl port-forward svc/argocd-server -n argo-cd 8080:443"
  description = "the port forward command for the argo-cd server, so you can login"
}
