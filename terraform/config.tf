variable "application_bucket_name" {
  type        = string
  description = "Application bucket name"
  default     = "application-bucket-6739970b1ca7"
}

variable "static_content_bucket_name" {
  type        = string
  description = "Static content bucket name"
  default     = "static-content-bucket-6739970b1ca7"
}

variable "force_destroy_bucket" {
  type        = string
  description = "Force destroy bucket"
  default     = true
}

variable "resource_owner_email" {
  type        = string
  description = "Resource owner email"
  default     = "not defined"
}

variable "domain_name" {
  type        = string
  description = "Domain nome"
  default     = "sarasa.com"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN"
  default     = "arn:aws:acm:us-east-1:123123123:certificate/123123123-123-123-123-123123123"
}
