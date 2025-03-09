variable "create_vpc" {
  description = "Create new VPC"
  type        = bool
  default     = false
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = list(string)
  default     = []
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}