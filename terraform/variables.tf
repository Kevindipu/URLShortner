variable "admin_ip" {
  description = "Public IPv4 address allowed to SSH into the application servers"
  type        = string
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "alert_email" {
  description = "Email address that receives CloudWatch alarm notifications"
  type        = string
}
