output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id  
}

output "private_subnet_id" {
    description = "The ID of the private subnet"
    value = aws_subnet.private.id
}

output "control_sg" {
    value = aws_security_group.k8s_control_sg.id
}

output "workers_sg" {
    value = aws_security_group.k8s_workers_sg.id
}

output "bastion_sg" {
    value = aws_security_group.bastion_sg.id
}