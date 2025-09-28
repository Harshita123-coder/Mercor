variable "name_prefix"     { type = string }
variable "subnet_ids"      { type = list(string) }
variable "vpc_id"          { type = string }
variable "cluster_name"    { type = string }
variable "instance_type"   { type = string }
variable "desired"         { type = number }
variable "max"             { type = number }
variable "ami_id"          { type = string, default = null }
variable "container_port"  { type = number }
variable "alb_sg_id"       { type = string }  # to allow ALB -> hosts ingress
