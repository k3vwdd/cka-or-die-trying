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
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.security_group_type == "jumpbox" ? [aws_security_group.jumpbox_sg.id] : [aws_security_group.kubernetes_sg.id]
  associate_public_ip_address = each.value.security_group_type == "jumpbox" ? true : false
  user_data                   = each.value.user_data_type == "jumpbox" ? file("../scripts/web_server_user_data_script.sh") : null
  key_name                    = aws_key_pair.cka_cluster_key.key_name
  tags = merge(local.common_tags, each.value.tags, {
    ProvisionedBy = "Terraform and k3vwd : )"
  })
}
