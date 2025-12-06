nsg-security-rules  = {
    rule1 ={
        name = "sshport"
        destination_port_range = "22"
        priority = 100
    }
     rule2 ={
        name = "rdpport"
        destination_port_range = "3789"
        priority = 101
    }
}
vnet-range = ["10.0.0.0/16"]
subnets = {
    app-subnet = {
        address_range = ["10.0.2.0/24"]
    }
    web-subnet = {
        address_range = ["10.0.3.0/24"]
    }
}

