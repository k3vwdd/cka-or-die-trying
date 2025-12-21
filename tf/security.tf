resource "aws_security_group" "jumpbox_sg" {
  name        = "jumpbox_sg"
  description = "Jumpbox for admin work - kube cluster"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.common_tags, {
    Name = "jumpbox_sg"
  })
}

resource "aws_security_group" "kubernetes_sg" {
  name        = "kubernetes_sg"
  description = "kube cluster security group networking"
  vpc_id      = data.aws_vpc.default_vpc.id

  # only traffic FROM an instance using jumpbox_sg can reach port 22
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
  }

  # Cluster internal traffic
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.common_tags, {
    Name = "kubernetes_sg"
  })
}

resource "aws_key_pair" "cka_cluster_key" {
  key_name   = "cka_cluster_key"
  public_key = var.ssh_public_key
  tags = merge(local.common_tags, {
    Name = "cka_cluster_key"
  })
}
