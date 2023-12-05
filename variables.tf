#variable for vpc
variable "ars_vpc" {
  type = string
  default = "10.0.0.0/16"
  description = "creating vpc in ap-south-1"
}

#variable for subnet
variable "pub_subnet" {
  type = string
  description = "public subnet"
  default = "10.0.1.0/24"
}
