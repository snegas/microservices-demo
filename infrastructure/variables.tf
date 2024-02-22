variable "type" {
  type        = string
  default     = "app"
  description = "Infrastructure type, can be either app or shared"

  validation {
    condition     = contains(["shared", "app"], var.type)
    error_message = "Type must be either app or shared"
  }
}

variable "prefix" {
  type        = string
  description = "Prefix for all resources. Typically a project name"
}

variable "base_domain" {
  type        = string
  description = "DNS Hosted Zone you own and want to allocate as a base for the environments"
  default     = ""
}

variable "redis" {
  type        = bool
  description = "Do we need a Redis Cluster created or not?"
  default     = false
}

variable "external" {
  type        = bool
  description = "Do we need to create a load balancer, https cert and a DNS record?"
  default     = false
}