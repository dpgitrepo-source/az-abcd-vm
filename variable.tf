variable "nsg-security-rules" {
    type = map(object({
      name = string
      destination_port_range = string
    }))
  
}

variable "vnet-range" {
    type = list(string)
  
}

variable "subnets" {
  type = map(object({
    address_range = list(string)
  }))
}