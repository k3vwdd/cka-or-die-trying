output "private_ips" {
  description = "Private ip's"
  value       = { for k, v in aws_instance.my_kube_cluster : k => v.private_ip }
}

output "instance_ids" {
  description = "Instance id's"
  value       = { for k, v in aws_instance.my_kube_cluster : k => v.id }
}

output "ami_name" {
  description = "Outputs the ami names to confirm correct image name"
  value       = data.aws_ami.debian_12.name
}

output "ami_id" {
  description = "Outputs the ami ids to confirm correct image id"
  value       = data.aws_ami.debian_12.id
}
