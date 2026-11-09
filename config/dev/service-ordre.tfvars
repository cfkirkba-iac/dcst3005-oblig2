service = "ordre"
runtime = "vm"
prefix  = "10.10.0.0/24"

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMQ32gu8mGVI86gkUex5JsBeg7WC58bsUOVuxmeHDJW oblig2-ingen-privat-nokkel"

extra_inbound_rules = [
  {
    name                   = "allow-tcp-8913"
    priority               = 110
    protocol               = "Tcp"
    source_address_prefix  = "172.16.225.0/24"
    destination_port_range = "8913"
  }
]
