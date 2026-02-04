locals {
  name_prefix = var.project_name
  ports_http  = 80
  ports_ssh   = 22
  ports_https = 443
  # ports_dns = 53
  db_port        = 3306
  tcp_protocol   = "tcp"
  udp_protocol   = "udp"
  all_ip_address = "0.0.0.0/0"
  # For AWS SG rules, "all protocols" is represented by ip_protocol = "-1".
  # When ip_protocol = "-1", AWS expects from_port/to_port to be 0.
  all_ports    = 0
  all_protocol = "-1"
}
# VPC & IGW#######
resource "aws_vpc" "deathstar_vpc01" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc01"
  }
}
resource "aws_internet_gateway" "deathstar_igw01" {
  vpc_id = aws_vpc.deathstar_vpc01.id

  tags = {
    Name = "${local.name_prefix}-igw01"
  }
}
##############################################################
# Subnets public and private
############################################

resource "aws_subnet" "deathstar_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.deathstar_vpc01.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "deathstar_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.deathstar_vpc01.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${local.name_prefix}-private-${count.index + 1}"
  }
}
############# NAT Gateway + EIP ##########
# Explanation: deathstar wants the private base to call home—EIP gives the NAT a stable “holonet address.”
resource "aws_eip" "deathstar_nat_eip01" {
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip01"
  }
}
resource "aws_nat_gateway" "deathstar_nat01" {
  allocation_id = aws_eip.deathstar_nat_eip01.id
  subnet_id     = aws_subnet.deathstar_public_subnets[0].id # NAT in a public subnet

  tags = {
    Name = "${local.name_prefix}-nat01"
  }

  depends_on = [aws_internet_gateway.deathstar_igw01]
}
############################################
# Routing public and private
############################################

# Public route table: Internet access for the EC2 app host (reachable over HTTP)
resource "aws_route_table" "deathstar_public_rt01" {
  vpc_id = aws_vpc.deathstar_vpc01.id

  tags = {
    Name = "${local.name_prefix}-public-rt01"
  }
}

resource "aws_route" "deathstar_public_default_route" {
  route_table_id         = aws_route_table.deathstar_public_rt01.id
  destination_cidr_block = local.all_ip_address
  gateway_id             = aws_internet_gateway.deathstar_igw01.id
}

resource "aws_route_table_association" "deathstar_public_rta" {
  count          = length(aws_subnet.deathstar_public_subnets)
  subnet_id      = aws_subnet.deathstar_public_subnets[count.index].id
  route_table_id = aws_route_table.deathstar_public_rt01.id
}

# Private route table: no internet route (RDS stays private)
resource "aws_route_table" "deathstar_private_rt01" {
  vpc_id = aws_vpc.deathstar_vpc01.id

  tags = {
    Name = "${local.name_prefix}-private-rt01"
  }
}
# Explanation: Private subnets route outbound internet via NAT (deathstar-approved stealth).
resource "aws_route" "deathstar_private_default_route" {
  route_table_id         = aws_route_table.deathstar_private_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.deathstar_nat01.id
}
resource "aws_route_table_association" "deathstar_private_rta" {
  count          = length(aws_subnet.deathstar_private_subnets)
  subnet_id      = aws_subnet.deathstar_private_subnets[count.index].id
  route_table_id = aws_route_table.deathstar_private_rt01.id
}
############################################
# Security Groups (EC2 + RDS)
############################################

# Explanation: EC2 SG is Deathstar's bodyguard—only let in what you mean to.
resource "aws_security_group" "deathstar_ec2_sg01" {
  name        = "${local.name_prefix}-ec2-sg01"
  description = "EC2 app security group"
  vpc_id      = aws_vpc.deathstar_vpc01.id

  # TODO: student adds inbound rules (HTTP 80, SSH 22 from their IP)
  # TODO: student ensures outbound allows DB port to RDS SG (or allow all outbound)

  tags = {
    Name = "${local.name_prefix}-ec2-sg01"
  }
}

# Explanation: RDS SG is the Rebel vault—only the app server gets a keycard.
resource "aws_security_group" "deathstar_rds_sg01" {
  name        = "${local.name_prefix}-rds-sg01"
  description = "RDS security group"
  vpc_id      = aws_vpc.deathstar_vpc01.id

  # TODO: student adds inbound MySQL 3306 from aws_security_group.deathstar_ec2_sg01.id

  tags = {
    Name = "${local.name_prefix}-rds-sg01"
  }
}
############################################
# RDS Subnet Group + RDS Instance (MySQL)
############################################

resource "aws_db_subnet_group" "deathstar_rds_subnet_group01" {
  name       = "${local.name_prefix}-rds-subnet-group01"
  subnet_ids = aws_subnet.deathstar_private_subnets[*].id

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group01"
  }
}

resource "aws_db_instance" "deathstar_rds01" {
  identifier               = "lab-mysql"
  engine                   = var.db_engine
  instance_class           = var.db_instance_class
  storage_type             = var.storage_type
  allocated_storage        = 20
  backup_retention_period  = 0
  db_name                  = var.db_name
  username                 = var.db_username
  password                 = var.db_password
  multi_az                 = false
  delete_automated_backups = false

  db_subnet_group_name   = aws_db_subnet_group.deathstar_rds_subnet_group01.name
  vpc_security_group_ids = [aws_security_group.deathstar_rds_sg01.id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "lab-mysql"
  }

  depends_on = [aws_db_subnet_group.deathstar_rds_subnet_group01, aws_security_group.deathstar_rds_sg01]
}
############################################
# IAM Role + Instance Profile for EC2
############################################
#refuse to carry static keys—this role lets EC2 assume permissions safely.
resource "aws_iam_role" "deathstar_ec2_role01" {
  name = "${local.name_prefix}-ec2-role01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "deathstar_secrets_policy" {
  name        = "${local.name_prefix}-secrets-read-lab-rds-mysql"
  description = "Least-privilege Secrets Manager read access for lab secret only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadLabSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.deathstar_db_secret01.arn
      }
    ]
  })
}
#These policies are your toolbelt—tighten them (least privilege) as a stretch goal.
resource "aws_iam_role_policy_attachment" "deathstar_ec2_secrets_attach" {
  role       = aws_iam_role.deathstar_ec2_role01.name
  policy_arn = aws_iam_policy.deathstar_secrets_policy.arn
}
#Instance profile is the harness that straps the role onto the EC2 like bandolier ammo.
resource "aws_iam_instance_profile" "deathstar_instance_profile01" {
  name = "${local.name_prefix}-instance-profile01"
  role = aws_iam_role.deathstar_ec2_role01.name
}

############################################
# EC2 Instance (App Host)
############################################
resource "aws_instance" "private_ec2" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.private_subnet_ids[0]
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.deathstar_instance_profile01.name

  vpc_security_group_ids = [
    aws_security_group.private_ec2_sg.id
  ]

   user_data = file("${path.module}/1a_user_data.sh")

  tags = {
    Name = "${var.project_name}-private-ec2"
  }

}

resource "aws_security_group" "private_ec2_sg" {
  name        = "${var.project_name}-private-ec2-sg"
  description = "Allow only internal traffic"
  vpc_id      = var.vpc_id

  # Outbound allowed (needed for VPC endpoints)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-ec2-sg"
  }
}
############################################
# Parameter Store (SSM Parameters)
############################################

#Parameter Store is your map—endpoints and config live here for fast recovery.
resource "aws_ssm_parameter" "deathstar_db_endpoint_param" {
  name  = "/lab/db/endpoint"
  type  = "String"
  value = aws_db_instance.deathstar_rds01.address

  tags = {
    Name = "${local.name_prefix}-param-db-endpoint"
  }
}
#Ports are boring, but even you need to know which door number to kick in.
resource "aws_ssm_parameter" "deathstar_db_port_param" {
  name  = "/lab/db/port"
  type  = "String"
  value = tostring(aws_db_instance.deathstar_rds01.port)

  tags = {
    Name = "${local.name_prefix}-param-db-port"
  }
}

#DB name is the label on the crate—without it, you’re rummaging in the dark.
resource "aws_ssm_parameter" "deathstar_db_name_param" {
  name  = "/lab/db/name"
  type  = "String"
  value = var.db_name

  tags = {
    Name = "${local.name_prefix}-param-db-name"
  }
}
############################################
# Secrets Manager (lab/rds/mysql)
############################################
# Explanation: Secrets Manager is deathstar’s locked holster—credentials go here, not in code.
resource "aws_secretsmanager_secret" "deathstar_db_secret01" {
  name                    = "lab1a/rds/mysql"
  recovery_window_in_days = 0
}
# Explanation: Secret payload—students should align this structure with their app (and support rotation later).
resource "aws_secretsmanager_secret_version" "deathstar_db_secret_version01" {
  secret_id = aws_secretsmanager_secret.deathstar_db_secret01.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.deathstar_rds01.address
    port     = aws_db_instance.deathstar_rds01.port
    dbname   = var.db_name
  })

  depends_on = [aws_db_instance.deathstar_rds01]
}
############################################
# CloudWatch Logs (Log Group)
############################################
# Explanation: When the Falcon is on fire, logs tell you *which* wire sparked—ship them centrally.
resource "aws_cloudwatch_log_group" "deathstar_log_group01" {
  name              = "/aws/ec2/${local.name_prefix}-rds-app"
  retention_in_days = 7

  tags = {
    Name = "${local.name_prefix}-log-group01"
  }
}
############################################
# Custom Metric + Alarm (Skeleton)
############################################

# Explanation: Metrics are deathstar’s growls—when they spike, something is wrong.
# NOTE: Students must emit the metric from app/agent; this just declares the alarm.
resource "aws_cloudwatch_metric_alarm" "deathstar_db_alarm01" {
  alarm_name          = "${local.name_prefix}-db-connection-failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DBConnectionErrors"
  namespace           = "Lab/RDSApp"
  period              = 300
  statistic           = "Sum"
  threshold           = 3

  alarm_actions       = [aws_sns_topic.deathstar_sns_topic01.arn]

  tags = {
    Name = "${local.name_prefix}-alarm-db-fail"
  }
}
############################################
# SNS (PagerDuty simulation)
############################################

# Explanation: SNS is the distress beacon—when the DB dies, the galaxy (your inbox) must hear about it.
resource "aws_sns_topic" "deathstar_sns_topic01" {
  name = "${local.name_prefix}-db-incidents"
}

# Explanation: Email subscription = “poor man’s PagerDuty”—still enough to wake you up at 3AM.
resource "aws_sns_topic_subscription" "deathstar_sns_sub01" {
  topic_arn = aws_sns_topic.deathstar_sns_topic01.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}