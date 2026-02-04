#Bonus-A outputs (append to outputs.tf)

# Explanation: These outputs prove deathstar built private hyperspace lanes (endpoints) instead of public chaos.
output "deathstar_vpce_ssm_id" {
  value = aws_vpc_endpoint.deathstar_vpce_ssm01.id
}

output "deathstar_vpce_logs_id" {
  value = aws_vpc_endpoint.deathstar_vpce_logs01.id
}

output "deathstar_vpce_secrets_id" {
  value = aws_vpc_endpoint.deathstar_vpce_secrets01.id
}

output "deathstar_vpce_s3_id" {
  value = aws_vpc_endpoint.deathstar_vpce_s3_gw01.id
}

output "deathstar_private_ec2_instance_id_bonus" {
  value = aws_instance.deathstar_ec201_private_bonus.id
}