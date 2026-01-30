variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
 
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string

}

variable "public_subnet2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
  
}   

variable "private_subnet1_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  
}

variable "private_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
}

