resource "aws_instance" "my_kube_cluster" {
  for_each      = var.kube_server_farm
  ami           = data.aws_ami.debian_12.id
  instance_type = each.value.instance_type
  root_block_device {
    volume_size           = each.value.root_block_device.volume_size
    volume_type           = each.value.root_block_device.volume_type
    delete_on_termination = each.value.root_block_device.delete_on_termination
    encrypted             = each.value.root_block_device.encrypted
  }
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = each.value.security_group_type == "jumpbox" ? [aws_security_group.jumpbox_sg.id] : [aws_security_group.kubernetes_sg.id]
  associate_public_ip_address = each.value.security_group_type == "jumpbox" ? true : false
  iam_instance_profile        = aws_iam_instance_profile.kube_cluster_profile.name
  user_data = each.value.user_data_type == "jumpbox" ? templatefile("../scripts/jumpbox_user_data.sh", {
    s3_bucket = aws_s3_bucket.ssh_key_distribution.id
    }) : templatefile("../scripts/kube_node_user_data.sh", {
    s3_bucket = aws_s3_bucket.ssh_key_distribution.id
  })
  key_name = aws_key_pair.cka_cluster_key.key_name
  tags = merge(local.common_tags, each.value.tags, {
    ProvisionedBy = "Terraform and k3vwd : )"
  })
}
