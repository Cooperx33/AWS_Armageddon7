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
