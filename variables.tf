# Create variables for aws region, vpc cidr blocks, public subnet cidr blocks, private subnet cidr blocks
#, and AMI ID

variable "aws_region" {
  description = "value of the region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr_block" {
  description = "value of the vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "value of the public subnet cidr block"
  type        = string
  default     = "10.0.0.0/20"
}

variable "private_subnet_cidr_block" {
  description = "value of the private subnet cidr block"
  type        = string
  default     = "10.0.16.0/20"
}

variable "ami_id" {
  description = "value of the ami id"
  type        = string
  default     = "ami-0d2f97c8735a48a15"
}

variable "availability_zone" {
  description = "value of the availability zone"
  type        = string
  default     = "us-east-2a"
}
