variable "subnet_id" {
  type = string
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "allocate_eip" {
  type = bool
}

variable "add_db_subnet_route" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
