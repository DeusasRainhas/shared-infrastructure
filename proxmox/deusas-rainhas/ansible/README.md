# Ansible Playbooks - Server Hardening

This repository contains Ansible playbooks responsible for hardening and configuring servers in both Development (DEV) and Production (PROD) environments within the "Colmeia" (Beehive) infrastructure.

## Overview

The playbooks in this directory automate the security hardening process for servers running in the Proxmox virtualization environment, ensuring consistent security configurations across all environments.

## Features

- **Security Hardening**: Implements security best practices and configurations
- **Multi-Environment Support**: Separate configurations for DEV and PROD environments
- **Automated Configuration**: Reduces manual configuration errors and ensures consistency
- **Proxmox Integration**: Optimized for virtual machines running on Proxmox VE

## Prerequisites

- Ansible 2.9 or higher
- SSH access to target servers
- Python 3.x on target machines
- Proper inventory configuration

## Directory Structure

```
ansible/
├── README.md           # This file
├── playbooks/          # Main playbooks
├── roles/              # Ansible roles
├── inventory/          # Inventory files for different environments
├── group_vars/         # Group variables
├── host_vars/          # Host-specific variables
└── ansible.cfg        # Ansible configuration
```




## Quick Start

### Generate a new SSH key for Ansible
ssh-keygen -t ed25519 -f ~/.ssh/ssh_private_key_file_abelha_rainha -C "ansible@automation"

### Set correct permissions
chmod 600 ~/.ssh/ssh_private_key_file_abelha_rainha
chmod 644 ~/.ssh/ssh_private_key_file_abelha_rainha.pub

### Copy the key to the remote host
ssh-copy-id -i ~/.ssh/ssh_private_key_file_abelha_rainha.pub @dev.abelharainha.local
ssh-copy-id -i ~/.ssh/ssh_private_key_file_abelha_rainha.pub @prod.abelharainha.local
ssh-copy-id -i ~/.ssh/ssh_private_key_file_abelha_rainha.pub @runner.abelharainha.local

1. **Configure Inventory**: Update the inventory files with your server details
2. **Review Variables**: Check and modify variables in `group_vars/` and `host_vars/`
3. **Run Playbook**: Execute the hardening playbook

```bash
# For development environment
ansible-playbook -i inventory/dev playbooks/hardening.yml

# For production environment
ansible-playbook -i inventory/prod playbooks/hardening.yml
```

## Security Measures Implemented

- System updates and security patches
- Firewall configuration
- SSH hardening
- User access controls
- Service configuration and lockdown
- Log monitoring and rotation
- File system permissions
- Network security settings

## Contributing

When adding new playbooks or roles:

1. Follow Ansible best practices
2. Test in DEV environment first
3. Document any new variables or requirements
4. Update this README if necessary

## Environment Notes

- **DEV**: Used for testing and development purposes
- **PROD**: Production environment with stricter security policies

## Support

For issues or questions regarding these playbooks, please refer to the project documentation or contact the infrastructure team.