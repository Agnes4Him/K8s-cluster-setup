variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name prefix for all resources"
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet" {
  description = "private subnet CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

variable "azs" {
  description = "List of availability zones to deploy subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
  default     = "ami-0ecb62995f68bb549" # Ubuntu Server 24.04 LTS
}

variable "k8s_type" {
  description = "EC2 instance type"
  type        = string
  default = "t3.medium"
}

variable "bastion_type" {
  description = "EC2 instance type"
  type        = string
  default = "t2.micro"
}
