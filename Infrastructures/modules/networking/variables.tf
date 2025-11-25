variable "name" {
  description = "Prefix name for networking resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet" {
  description = "public subnet CIDR block"
  type        = string
}

variable "private_subnet" {
  description = "private subnet CIDR block"
  type        = string
}

variable "azs" {
  description = "List of availability zones to deploy subnets across"
  type        = list(string)
}