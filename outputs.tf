output "deathstar_vpc_id" {
  value = aws_vpc.deathstar_vpc01.id
}

output "deathstar_public_subnet_ids" {
  value = aws_subnet.deathstar_public_subnets[*].id
}

output "deathstar_private_subnet_ids" {
  value = aws_subnet.deathstar_private_subnets[*].id
}

output "lab_ec2_public_ip" {
  value = aws_instance.deathstar_ec2_01.public_ip
}

output "lab_ec2_public_dns" {
  value = aws_instance.deathstar_ec2_01.public_dns
}

output "lab_rds_endpoint" {
  value = aws_db_instance.deathstar_rds01.address
}

output "lab_secret_name" {
  value = aws_secretsmanager_secret.deathstar_db_secret01.name
}

output "lab_secret_arn" {
  value = aws_secretsmanager_secret.deathstar_db_secret01.arn
}