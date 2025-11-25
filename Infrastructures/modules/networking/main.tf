resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags = { Name = "${var.name}-subnet-public" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet
  availability_zone = var.azs[1]
  tags = { Name = "${var.name}-subnet-private"}
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-private-rt" }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-bastion"
  description = "Allow traffic to bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-bastion" }
}

resource "aws_security_group" "k8s_sg" {
  name        = "${var.name}-k8s"
  description = "Allow traffic from bastion to k8s nodes"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 2379
    to_port         = 2380
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-k8s" }
}

resource "aws_security_group_rule" "access_k8s_api" {
  type            = "ingress"
  from_port       = 6443
  to_port         = 6443
  protocol        = "tcp"
  security_group_id        = aws_security_group.k8s_sg.id
  source_security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "access_kubelet" {
  type            = "ingress"
  from_port       = 10250
  to_port         = 10250
  protocol        = "tcp"
  security_group_id        = aws_security_group.k8s_sg.id
  source_security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "access_etcd" {
  type            = "ingress"
  from_port       = 2379
  to_port         = 2380
  protocol        = "tcp"
  security_group_id        = aws_security_group.k8s_sg.id
  source_security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "allow_nodeport" {
  type            = "ingress"
  from_port       = 30000
  to_port         = 32767
  protocol        = "tcp"
  security_group_id        = aws_security_group.k8s_sg.id
  source_security_group_id = aws_security_group.k8s_sg.id
}