variable "name" {
  description = "Prefix name for compute resources"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "k8s_type" {
  description = "EC2 instance type"
  type        = string
}

variable "bastion_type" {
  description = "EC2 instance type"
  type        = string
}

variable "k8s_sg" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "bastion_sg" {
  description = "Security group ID for Bastion"
  type        = string
}

variable "private_subnet_id" {
  description = "private subnet ID where instance will launch"
  type        = string
}

variable "public_subnet_id" {
  description = "private subnet ID where instance will launch"
  type        =  string
}