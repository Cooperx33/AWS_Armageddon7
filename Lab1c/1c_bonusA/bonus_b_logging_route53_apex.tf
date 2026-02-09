# ############################################
# # Bonus B - Route53 Zone Apex + ALB Access Logs to S3
# ############################################

# ############################################
# # Route53: Zone Apex (root domain) -> ALB
# ############################################

# # Explanation: The zone apex is the throne room—deathstar-growl.com itself should lead to the ALB.
# resource "aws_route53_record" "deathstar_apex_alias01" {
#   zone_id = local.deathstar_.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.deathstar_alb01.dns_name
#     zone_id                = aws_lb.deathstar_alb01.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   # Use the Zone ID of the zone you are creating
#   zone_id = aws_route53_zone.deathstar_main.zone_id
  
#   # These are the exact values you just retrieved
#   name    = "_f879d4bbeffd712c5732029ce00cfd69.app.deathstardata.com."
#   type    = "CNAME"
#   ttl     = 60
#   records = ["_8a6dc7669d361cdb21a4d9cfdba0246a.jkddzztszm.acm-validations.aws."]
  
#   # This allows Terraform to update the record if you run it again
#   allow_overwrite = true
# }
# ############################################
# # S3 bucket for ALB access logs
# ############################################

# # Explanation: This bucket is deathstar’s log vault—every visitor to the ALB leaves footprints here.
# resource "aws_s3_bucket" "deathstar_alb_logs_bucket01" {
#   count = var.enable_alb_access_logs ? 1 : 0

#   bucket = "${var.project_name}-alb-logs-${data.aws_caller_identity.deathstar_self01.account_id}"

#   tags = {
#     Name = "${var.project_name}-alb-logs-bucket01"
#   }
# }

# # Explanation: Block public access—deathstar does not publish the ship’s black box to the galaxy.
# resource "aws_s3_bucket_public_access_block" "deathstar_alb_logs_pab01" {
#   count = var.enable_alb_access_logs ? 1 : 0

#   bucket                  = aws_s3_bucket.deathstar_alb_logs_bucket01[0].id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # Explanation: Bucket ownership controls prevent log delivery chaos—deathstar likes clean chain-of-custody.
# resource "aws_s3_bucket_ownership_controls" "deathstar_alb_logs_owner01" {
#   count = var.enable_alb_access_logs ? 1 : 0

#   bucket = aws_s3_bucket.deathstar_alb_logs_bucket01[0].id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# # Explanation: TLS-only—deathstar growls at plaintext and throws it out an airlock.
# resource "aws_s3_bucket_policy" "deathstar_alb_logs_policy01" {
#   count = var.enable_alb_access_logs ? 1 : 0

#   bucket = aws_s3_bucket.deathstar_alb_logs_bucket01[0].id

#   # NOTE: This is a skeleton. Students may need to adjust for region/account specifics.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "DenyInsecureTransport"
#         Effect    = "Deny"
#         Principal = "*"
#         Action    = "s3:*"
#         Resource = [
#           aws_s3_bucket.deathstar_alb_logs_bucket01[0].arn,
#           "${aws_s3_bucket.deathstar_alb_logs_bucket01[0].arn}/*"
#         ]
#         Condition = {
#           Bool = { "aws:SecureTransport" = "false" }
#         }
#       },
#       {
#         Sid    = "AllowELBPutObject"
#         Effect = "Allow"
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         }
#         Action   = "s3:PutObject"
#         Resource = "${aws_s3_bucket.deathstar_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.deathstar_self01.account_id}/*"
#       }
#     ]
#   })
# }

# ############################################
# # Enable ALB access logs (on the ALB resource)
# ############################################

# # Explanation: Turn on access logs—deathstar wants receipts when something goes wrong.
# # NOTE: This is a skeleton patch: students must merge this into aws_lb.deathstar_alb01
# # by adding/accessing the `access_logs` block. Terraform does not support "partial" blocks.
# #
# # Add this inside resource "aws_lb" "deathstar_alb01" { ... } in bonus_b.tf:
# #
# # access_logs {
# #   bucket  = aws_s3_bucket.deathstar_alb_logs_bucket01[0].bucket
# #   prefix  = var.alb_access_logs_prefix
# #   enabled = var.enable_alb_access_logs
# # }