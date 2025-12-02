# Proxmox VM Provisioning with Terraform

This Terraform configuration creates a virtual machine in Proxmox by cloning from an existing template (VM ID 1000).

#### Restore Storage
```bash
zpool import storage -f
```

#### Define backup path
```bash
pvesm add dir backup --content backup --path /storage/backup/proxmox
```

### Remove backup flag from the nvme (local)
```bash
pvesm set local --content vztmpl,iso
```


#### restore Backup Seed
```bash
qmrestore  vzdump-qemu-1000-2025_11_19-23_18_29.vma.zst 1000 --storage local-lvm
```



## Prerequisites

1. **Proxmox VE** server with API access
2. **Template VM** with ID 1000 (or change `template_vm_id` variable)
3. **Terraform** installed (v1.0+)
4. **Proxmox API Token** with appropriate permissions

## Creating Proxmox API Token

-  Log in to Proxmox web interface
   1. Navigate to **Datacenter → Permissions → API Tokens**
   2. Create a new token:
      ```
      User: root@pam
      Token ID: terraform
      Privilege Separation: Unchecked (for full permissions)
      ```
   3. Copy the generated token secret (shown only once)

- Cli
```bash
# create the user in proxmox
pveum user add terraform@pve --password your-secure-passwordddd
# create the user terraform as administrator
pveum aclmod / -user terraform@pve -role Administrator
# create the token for the user terraform
pveum user token add terraform@pve provider --privsep=0
```


## Configuration

### 1. Copy the example configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit `terraform.tfvars`

Configure the following key settings:

#### Proxmox Connection
```hcl
proxmox_endpoint   = "https://your-proxmox-server:8006"
proxmox_api_token  = "root@pam!terraform=your-token-secret"
proxmox_node_name  = "pve"  # Your Proxmox node name
```

## Usage

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Plan the deployment

```bash
terraform plan
```

### Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted to create the VM.


## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `proxmox_endpoint` | Proxmox API endpoint | - | Yes |
| `proxmox_api_token` | API token for authentication | - | Yes |
| `proxmox_node_name` | Proxmox node name | - | Yes |
| `template_vm_id` | Template VM ID to clone | 1000 | No |
| `vm_name` | Name for the new VM | - | Yes |
| `vm_cpu_cores` | Number of CPU cores | 2 | No |
| `vm_memory_mb` | Memory in MB | 2048 | No |
| `vm_disk_size_gb` | Disk size in GB | 20 | No |
| `vm_disk_datastore` | Datastore for VM disk | local-lvm | No |
| `vm_mac_address` | MAC address | auto | No |
| `vm_ipv4_address` | IPv4 address or "dhcp" | dhcp | No |
| `vm_ipv4_gateway` | IPv4 gateway | - | No |
| `vm_dns_servers` | DNS servers | ["192.168.1.5"] | No |


## Troubleshooting

### API Token Permission Issues

Ensure your API token has the following permissions:
- VM.Allocate
- VM.Clone
- VM.Config.Disk
- VM.Config.Memory
- VM.Config.Network
- Datastore.AllocateSpace

### Template Not Found

Verify template VM ID 1000 exists:
```bash
qm list | grep 1000
```

### Network Bridge Issues

Check available bridges:
```bash
brctl show
```

### SSL Certificate Errors

For self-signed certificates, set:
```hcl
proxmox_insecure = true
```

## Notes

- The VM will have the **QEMU guest agent enabled** for better integration
- Disk will use **iothread** and **discard** for better performance
- Template VM 1000 should be properly prepared with cloud-init or similar
- MAC address must be unique on your network if specified
