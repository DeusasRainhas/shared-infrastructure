variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint (e.g., https://proxmox.example.com:8006)"
  type        = string
  default     = ""
}

variable "create_seed" {
  description = "Whether to create the seed VM"
  type        = bool
  default     = true
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token in format 'user@realm!tokenid=secret'"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API (use true for self-signed certificates)"
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "Name of the Proxmox node where the VM will be created"
  type        = string
  default     = "proxmox"
}

variable "template_vm_id" {
  description = "The VM ID of the template to clone (e.g., 1000)"
  type        = number
  default     = 1000
}

variable "vms" {
  description = "Map of VMs to create with their configurations"
  type = map(object({
    vm_name            = string
    started_enabled    = bool
    vm_id              = number
    vm_tags            = list(string)
    vm_cpu_cores       = number
    vm_memory_mb       = number
    vm_disk_size_gb    = number
    vm_mac_address     = string
    onboot_enabled     = bool
    startup_order      = number
    startup_up_delay   = number
    startup_down_delay = number
  }))
}

variable "vm_description" {
  description = "Description of the virtual machine"
  type        = string
  default     = "VM created from Terraform"
}

variable "vm_cpu_type" {
  description = "CPU type for the VM (e.g., 'host', 'x86-64-v2-AES')"
  type        = string
  default     = "host"
}

variable "vm_disk_datastore" {
  description = "Datastore ID where the VM disk will be stored"
  type        = string
  default     = "local-lvm"
}

variable "vm_network_bridge" {
  description = "Network bridge to connect the VM to (e.g., 'vmbr0')"
  type        = string
  default     = "vmbr0"
}

variable "vm_ipv4_gateway" {
  description = "IPv4 gateway address (required when using static IP)"
  type        = string
  default     = ""
}

variable "vm_dns_servers" {
  description = "List of DNS server addresses"
  type        = list(string)
  default     = []
}

