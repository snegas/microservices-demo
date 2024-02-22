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