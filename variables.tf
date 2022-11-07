variable "enable_argocd" {
  type        = bool
  default     = true
  description = "enable argocd"
}

variable "enable_externalsecrets" {
  type        = bool
  default     = false
  description = "enable external-secrets operator"
}

variable "namespace_name" {
  type        = string
  default     = "test"
  description = "a namespace to test in"
}

variable "blue_green_namespace_name" {
  type        = string
  default     = "blue-green"
  description = "another namespace to test in"
}

variable "enable_blue_green_app" {
  type        = bool
  default     = false
  description = "enable the blue-green demo app"
}

variable "enable_multicluster" {
  type        = bool
  default     = false
  description = "enable a multicluster setup"
}

variable "cluster_worker_count" {
  type        = number
  default     = 1
  description = "the number of additional clusters"
}

variable "enable_ingress" {
  type        = bool
  default     = false
  description = "enable ingress"
}

variable "ingress_type" {
  type        = string
  default     = "nginx"
  description = "type of ingress, possible values 'nginx', 'traefik'"
}

variable "argo_ingress_host" {
  type        = string
  default     = "argocd.local"
  description = "the host used argocd"
}

variable "traefik_ingress_host" {
  type        = string
  default     = "traefik.local"
  description = "the host used for traefik"
}
