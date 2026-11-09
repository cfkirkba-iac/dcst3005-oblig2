variable "kortnavn" {
  description = "Kortnavnet ditt."
  type        = string
}

variable "location" {
  description = "Azure-regionen."
  type        = string
}

variable "miljo" {
  description = "Miljøet."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.miljo)
    error_message = "miljo må være dev eller prod."
  }
}

variable "state_resource_group_name" {
  description = "Ressursgruppa til state-kontoen."
  type        = string
}

variable "state_storage_account_name" {
  description = "State-kontoen."
  type        = string
}

variable "state_container_name" {
  description = "Containeren state ligger i."
  type        = string
}

variable "service" {
  description = "Navnet på tjenesten."
  type        = string
}

variable "runtime" {
  description = "Kjøremiljøet: vm eller webapp."
  type        = string

  validation {
    condition     = contains(["vm", "webapp"], var.runtime)
    error_message = "runtime må være vm eller webapp."
  }
}

variable "prefix" {
  description = "Adresseområdet til tjenestens subnett."
  type        = string
}

variable "allow_http_from" {
  description = "Hvem som får nå tjenesten på port 80."
  type        = string
  default     = "Internet"
}

variable "vm_size" {
  description = "VM-størrelse når runtime er vm."
  type        = string
  default     = "Standard_B2als_v2"
}

variable "ssh_public_key" {
  description = "Offentlig SSH-nøkkel når runtime er vm."
  type        = string
  default     = null
}

variable "webapp_sku" {
  description = "App Service-SKU når runtime er webapp."
  type        = string
  default     = "B1"
}

variable "extra_inbound_rules" {
  description = "Ekstra innkommende NSG-regler for tjenesten."
  type = list(object({
    name                   = string
    priority               = number
    protocol               = string
    source_address_prefix  = string
    destination_port_range = string
  }))
  default = []
}
