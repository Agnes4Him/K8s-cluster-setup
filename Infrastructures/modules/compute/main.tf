data "aws_key_pair" "bastion_key" {
  key_name = "bastion-key"
}

data "aws_key_pair" "k8s_key" {
  key_name = "k8s-key"
}

resource "aws_instance" "k8s_control" {
    ami           = var.ami 
    instance_type = var.k8s_type

    subnet_id              = var.private_subnet_id
    security_groups        = [var.k8s_control_sg]
    key_name               = data.aws_key_pair.k8s_key.key_name

    tags = {
        Name = "${var.name}-control-node"
    }
}

resource "aws_instance" "k8s_workers" {
    count         = 2
    ami           = var.ami 
    instance_type = var.k8s_type

    subnet_id              = var.private_subnet_id
    security_groups        = [var.k8s_workers_sg]
    key_name               = data.aws_key_pair.k8s_key.key_name

    tags = {
        Name = "${var.name}-worker-node${count.index}"
    }
}

resource "aws_instance" "bastion" {
    ami           = var.ami
    instance_type = var.bastion_type

    subnet_id              = var.public_subnet_id
    security_groups        = [var.bastion_sg]
    key_name               = data.aws_key_pair.bastion_key.key_name
    associate_public_ip_address = true

    tags = {
        Name = "${var.name}-bastion"
    }
}