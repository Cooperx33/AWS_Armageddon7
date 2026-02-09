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
# Explanation: Outputs are the mission coordinates — where to point your browser and your blasters.
output "deathstar_alb_dns_name" {
  value = aws_lb.deathstar_alb01.dns_name
}

output "deathstar_app_fqdn" {
  value = "${var.app_subdomain}.${var.domain_name}"
}

output "deathstar_target_group_arn" {
  value = aws_lb_target_group.deathstar_tg01.arn
}

output "deathstar_acm_cert_arn" {
  value = aws_acm_certificate.deathstar_acm_cert01.arn
}

output "deathstar_waf_arn" {
  value = var.enable_waf ? aws_wafv2_web_acl.deathstar_waf01[0].arn : null
}

output "deathstar_dashboard_name" {
  value = aws_cloudwatch_dashboard.deathstar_dashboard01.dashboard_name
}

