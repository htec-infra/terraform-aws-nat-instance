//output "eni_ids" {
//  description = "ID of the ENI for the NAT instance"
//  value       = module.net_interface.*.eni_id
//}
//
//output "eni_private_ip" {
//  description = "Private IP of the ENI for the NAT instance"
//  value = tolist(aws_network_interface.this.private_ips)[0]
//}

output "sg_id" {
  description = "ID of the security group of the NAT instance"
  value       = aws_security_group.this.id
}

output "iam_role_name" {
  description = "Name of the IAM role for the NAT instance"
  value       = aws_iam_role.this.name
}
