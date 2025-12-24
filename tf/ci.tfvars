# CI/CD configuration file - contains non-sensitive infrastructure config
# Sensitive values (ssh_public_key, allowed_ssh_cidr) are passed via GitHub Secrets

kube_server_farm = {
  jumpbox_administration_host = {
    instance_type = "t2.nano"
    root_block_device = {
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
    security_group_type = "jumpbox"
    user_data_type      = "jumpbox"
    tags = {
      Name        = "Jumpbox Server"
      Environment = "Dev"
    }
  }
  kubernetes_server = {
    instance_type = "t2.small"
    root_block_device = {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
    security_group_type = "kubernetes"
    user_data_type      = "kubernetes"
    tags = {
      Name        = "Kubernetes Server"
      Environment = "Dev"
    }
  }
  node_0_Kubernetes_worker_node = {
    instance_type = "t2.small"
    root_block_device = {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
    security_group_type = "kubernetes"
    user_data_type      = "kubernetes"
    tags = {
      Name        = "Kubernetes worker node 0"
      Environment = "Dev"
    }
  }
  node_1_Kubernetes_worker_node = {
    instance_type = "t2.small"
    root_block_device = {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
    security_group_type = "kubernetes"
    user_data_type      = "kubernetes"
    tags = {
      Name        = "Kubernetes worker node 1"
      Environment = "Dev"
    }
  }
}
