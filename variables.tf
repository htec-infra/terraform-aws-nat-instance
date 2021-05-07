variable "enabled" {
  description = "Enable or not costly resources"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Module namespace"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "name" {
  description = "Name for all the resources as identifier"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "IDs of the public subnets to place the NAT instance"
  type        = list(string)
}

variable "image_id" {
  description = "AMI of the NAT instance. Default to the latest Amazon Linux 2"
  type        = string
  default     = ""
}

variable "instance_types" {
  description = "Candidates of spot instance type for the NAT instance. This is used in the mixed instances policy"
  type        = list(string)
  default     = ["t3a.nano", "t3.nano"]
}

variable "allocate_elastic_ip" {
  type    = bool
  default = false
}

variable "use_spot_instance" {
  description = "Whether to use spot or on-demand EC2 instance"
  type        = bool
  default     = true
}

variable "health_check_grace_period" {
  description = "How long ASG should wait before a health-check starts"
  type        = number
  default     = 180
}

variable "key_name" {
  description = "Name of the key pair for the NAT instance. You can set this to assign the key pair to the NAT instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to resources created with this module"
  type        = map(string)
  default     = {}
}
