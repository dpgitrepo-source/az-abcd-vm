variable "nsg-security-rules" {
    type = map(object({
      name = string
      destination_port_range = string
      priority = number
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