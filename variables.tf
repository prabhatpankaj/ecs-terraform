variable "aws_region" {
  description = "AWS region"
  default = "ap-south-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  default = "vpc-04e390a07af619697"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default = ["subnet-0bc03f50e3492bcf0","subnet-009fb17d01973e68a","subnet-0e025d2505799905d"]
}

variable "security_grp" {
  description = "ID of the security group"
  default = "sg-0ed7198e6205bfff1"
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  default = "nginx-cluster"
}
