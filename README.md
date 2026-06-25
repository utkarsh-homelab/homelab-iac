# homelab-iac

Automation for Kubernetes cluster on Proxmox using Terraform + Ansible.

## Quick Start

```bash
# 0. Create API token on proxmox

# 1. Provision VMs
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in your values
terraform init && terraform apply               # creates VMs, prints MACs

# 2. Reserve IPs on your router using the MAC addresses from step 1
```

## Structure

| Directory | Purpose |
|---|---|
| `terraform/` | Proxmox VM provisioning (`bpg/proxmox`) |

## Prerequisites

- Terraform >= 1.5
- Proxmox with Ubuntu cloud-init template (ID 9000)
- Proxmox API token
- SSH key pair