variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
  default     = "10.0.1.0/24"
}   

variable "private_subnet1_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
  default     = "10.0.3.0/24"
}
