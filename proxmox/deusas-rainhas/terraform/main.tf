# ============================================================================
# TEMPLATE-BASED VM PROVISIONING
# ============================================================================
# This resource clones VMs from existing Proxmox templates using for_each
# to support multiple VMs with different configurations.

resource "proxmox_virtual_environment_vm" "vm_from_template" {
  for_each = var.vms

  # Basic VM Configuration
  vm_id       = each.value.vm_id        # Unique VM identifier in Proxmox
  name        = each.value.vm_name      # Human-readable VM name (FQDN recommended)
  description = var.vm_description      # Description shown in Proxmox UI
  tags        = each.value.vm_tags      # Tags for organization and filtering
  node_name   = var.proxmox_node_name   # Target Proxmox node for VM placement

  # Clone from Template
  # Clones from template defined in var.template_vm_id with automatic retries
  clone {
    vm_id   = var.template_vm_id  # Source template VM ID
    retries = 3                   # Retry clone operation up to 3 times on failure
  }
  started  = each.value.started_enabled  # Whether to start VM immediately after creation
  # Startup Configuration
  # Controls boot order and delays for coordinated multi-VM startup sequences
  startup {
    order      = each.value.startup_order      # Boot order (lower numbers start first)
    up_delay   = each.value.startup_up_delay   # Seconds to wait after VM starts
    down_delay = each.value.startup_down_delay # Seconds to wait after VM stops
  }

  # QEMU Guest Agent
  # Enables enhanced VM management and reporting (IP addresses, resource usage)
  agent {
    enabled = true
  }

  # CPU Configuration
  cpu {
    cores = each.value.vm_cpu_cores  # Number of CPU cores per socket
    type  = var.vm_cpu_type          # CPU type (e.g., "host" for best performance)
  }

  # Auto-start Configuration
  # Whether VM should auto-start when Proxmox node boots
  on_boot = each.value.onboot_enabled

  # Memory Configuration
  memory {
    dedicated = each.value.vm_memory_mb  # Dedicated RAM in MB
  }

  # Disk Configuration
  # Primary disk for OS and data
  disk {
    datastore_id = var.vm_disk_datastore  # Storage location (e.g., "local-lvm")
    interface    = "scsi0"                # Disk interface (scsi0 for first SCSI disk)
    size         = each.value.vm_disk_size_gb  # Disk size in GB
    iothread     = true                   # Enable dedicated I/O thread for performance
    discard      = "on"                   # Enable TRIM/discard for thin provisioning
  }

  # Network Configuration
  # Primary network interface
  network_device {
    bridge      = var.vm_network_bridge      # Network bridge (e.g., "vmbr0")
    mac_address = each.value.vm_mac_address  # Fixed MAC address for consistent DHCP
  }
}

# Template-Based VM Outputs
# -------------------------

output "vm_ids" {
  description = "Map of VM keys to their Proxmox VM IDs"
  value       = { for k, v in proxmox_virtual_environment_vm.vm_from_template : k => v.id }
}

output "vm_names" {
  description = "Map of VM keys to their hostnames"
  value       = { for k, v in proxmox_virtual_environment_vm.vm_from_template : k => v.name }
}

output "vm_ipv4_addresses" {
  description = "Map of VM keys to their primary IPv4 addresses (requires QEMU guest agent and VM running)"
  value = {
    for k, v in proxmox_virtual_environment_vm.vm_from_template :
    # Only attempt to read IP if VM is started and guest agent is available
    # ipv4_addresses[0] is loopback (127.0.0.1), [1][0] is first real interface
    k => (v.started && length(v.ipv4_addresses) > 1) ? v.ipv4_addresses[1][0] : null
  }
}
