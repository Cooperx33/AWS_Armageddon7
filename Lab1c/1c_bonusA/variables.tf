variable "aws_region" {
  description = "AWS Region for the deathstar lab environment."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Prefix for naming (used in tags and resource names)."
  type        = string
  default     = "deathstar"
}

variable "vpc_cidr" {
  description = "VPC CIDR (use 10.x.x.x/xx as instructed)."
  type        = string
  default     = "10.13.0.0/16" # TODO: student supplies
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (use 10.x.x.x/xx)."
  type        = list(string)
  default     = ["10.13.1.0/24", "10.13.2.0/24"] # TODO: student supplies
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (use 10.x.x.x/xx)."
  type        = list(string)
  default     = ["10.13.21.0/24", "10.13.22.0/24"] # TODO: student supplies
}

variable "azs" {
  description = "Availability Zones list (match count with subnets)."
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"] # TODO: student supplies
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 app host."
  type        = string
  default     = "ami-06f1fc9ae5ae7f31e" # TODO
}

variable "ec2_instance_type" {
  description = "EC2 instance size for the app."
  type        = string
  default     = "t3.micro"
}


variable "key_name" {
  description = "Optional EC2 key pair name. Leave null/empty to avoid SSH keys (SSM recommended)."
  type        = string
  default     = null
}
variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}


variable "storage_type" {
  description = "RDS storage type (gp3 recommended)."
  type        = string
  default     = "gp3"
}
variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "labdb" # Students can change
}

variable "db_username" {
  description = "DB master username (students should use Secrets Manager in 1B/1C)."
  type        = string
  default     = "admin" # TODO: student supplies
}

variable "db_password" {
  description = "DB master password (DO NOT hardcode in real life; for lab only)."
  type        = string
  sensitive   = true
  default     = "REPLACE_ME" # TODO: student supplies
}

variable "sns_email_endpoint" {
  description = "Email for SNS subscription (PagerDuty simulation)."
  type        = string
  default     = "cooperx33@gmail.com" # TODO: student supplies
  
}
variable "vpc_id" {
  description = "Existing VPC ID to deploy resources into."
  type        = string
  
}
######## Lab 1C Bonus_B variables ##########
variable "domain_name" {
  description = "Base domain students registered (e.g., deathstardata.com)."
  type        = string
  default     = "deathstardata.com"
}

variable "app_subdomain" {
  description = "App hostname prefix (e.g., app.deathstardata.com)."
  type        = string
  default     = "app"
}

variable "certificate_validation_method" {
  description = "ACM validation method. Students can do DNS (Route53) or EMAIL."
  type        = string
  default     = "DNS"
}

variable "enable_waf" {
  description = "Toggle WAF creation."
  type        = bool
  default     = true
}

variable "alb_5xx_threshold" {
  description = "Alarm threshold for ALB 5xx count."
  type        = number
  default     = 10
}

variable "alb_5xx_period_seconds" {
  description = "CloudWatch alarm period."
  type        = number
  default     = 300
}

variable "alb_5xx_evaluation_periods" {
  description = "Evaluation periods for alarm."
  type        = number
  default     = 1
}
variable "create_route53_zone" {
  description = "Create a public Route53 hosted zone for domain_name when using DNS validation."
  type        = bool
  default     = true
}
variable "enable_alb_access_logs" {
  description = "Boolean to enable or disable ALB access logging to S3"
  type        = bool
  default     = true # Or false, depending on your preference
}
variable "alb_access_logs_prefix" {
  description = "The S3 folder prefix where ALB logs will be stored"
  type        = string
  default     = "alb-logs"
}