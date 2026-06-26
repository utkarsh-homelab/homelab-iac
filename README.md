# homelab-iac

Automation for Kubernetes cluster lifecycle on Proxmox - Terraform provisions VMs, Ansible configures the cluster and bootstraps ArgoCD with self-management.

## Prerequisites

| Requirement | Detail |
|---|---|
| Terraform | >= 1.5 |
| Ansible | >= 2.15 |
| Proxmox | PVE 8.x with API token |
| Template | Ubuntu 22.04/24.04 cloud-init VM (ID 9000) |
| SSH key | Injected via cloud-init, used by Ansible |
| Helm | Installed on control node (for ArgoCD manifest generation) |
| Router | DNSMASQ or pfSense with DHCP reservation |

---

## Quick Start

```bash
# 0. Create API token on proxmox

# 1. Provision VMs
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in your values
cp secrets.auto.tfvars.example secrets.auto.tfvars   # fill in API token
terraform init && terraform apply               # creates VMs, prints MACs

# 2. Reserve IPs on your router using the MAC addresses from step 1

# 3. Fill Ansible inventory with the reserved IPs
vim ../ansible/inventory/hosts.yaml

# 4. Bootstrap the cluster
cd ../ansible
ansible-playbook playbooks/cluster.yaml         # full k8s cluster setup

# 5. Deploy ArgoCD
ansible-playbook playbooks/argocd.yaml           # CRDs + manifests + wait

# 6. Apply root App of Apps
ansible-playbook playbooks/argocd.yaml --tags root-app
```

---

## Repository Layout

```
homelab-iac/
├── .gitignore
├── README.md
│
├── terraform/                        # Infrastructure as Code
│   ├── provider.tf                   # Proxmox (bpg/proxmox) provider config
│   ├── variables.tf                  # Input variables
│   ├── main.tf                       # Module calls (one per VM)
│   ├── outputs.tf                    # MAC addresses for DHCP
│   ├── terraform.tfvars.example      # Example non-secret vars
│   ├── secrets.auto.tfvars.example   # Example secrets (gitignored)
│   └── modules/
│       └── k8s-vm/                   # Reusable VM module
│           ├── variables.tf
│           ├── main.tf               # proxmox_virtual_environment_vm resource
│           └── outputs.tf
│
└── ansible/                          # Configuration Management
    ├── ansible.cfg                   # Default inventory, disable host key checking
    ├── inventory/
    │   └── hosts.yaml                # Node IPs + localhost entry (fill in IPs after DHCP reservation)
    ├── group_vars/
    │   └── all.yaml                  # Global vars (k8s version, CNI choice, etc.)
    ├── playbooks/
    │   ├── cluster.yaml              # Full cluster bootstrap (common + kubeadm + cni)
    │   └── argocd.yaml               # ArgoCD bootstrap 
    └── roles/
        ├── common/                     # containerd, kernel, swap
        ├── kubeadm/                    # k8s packages + init/join
        ├── cni/                        # pluggable CNI (flannel/cilium)
        └── argocd/                     # CRDs + helm template + apply
```
---

## Variables

### Terraform (`terraform.tfvars`)

| Variable | Description | Default |
|---|---|---|
| `proxmox_endpoint` | Proxmox API URL | — |
| `proxmox_insecure` | Skip TLS verification | `false` |
| `template_id` | VM template to clone | `9000` |
| `bridge` | Proxmox network bridge | `vmbr0` |
| `storage` | Proxmox storage pool | `local-lvm` |
| `vms` | Map of VM definitions | — |

Secrets go in `secrets.auto.tfvars` (gitignored):

| Variable | Description |
|---|---|
| `proxmox_api_token` | `USER@REALM!TOKENID=UUID` format |

### Ansible (`group_vars/all.yaml`)

| Variable | Description | Default |
|---|---|---|
| `kubernetes_version` | k8s apt repo version | `1.36` |
| `kubernetes_package_version` | k8s package version | `1.36.2-2.1` |
| `pod_network_cidr` | Pod CIDR | `10.244.0.0/16` |
| `cni_plugin` | CNI to deploy | `flannel` |
| `argocd_helm_version` | Helm chart version | `9.7.0` |
| `argocd_version` | App version (for CRD URLs) | `v3.4.4` |
| `argocd_url` | External ArgoCD URL | `https://argocd.uttutu.xyz` |
| `argocd_gitops_repo` | GitOps repo for root App | `https://github.com/utkarsh-homelab/homelab-gitops` |
| `argocd_values_url` | Remote Helm values URL | `https://raw.githubusercontent.com/.../prod.yaml` |

---

## Usage

### Playbook Tags

**`cluster.yaml`**

| Tag | Scope |
|---|---|
| `common` | containerd, kernel modules, sysctl, swap |
| `kubeadm` | k8s packages + init (control) or join (workers) |
| `cni` | Deploy overlay network |
| `control` | Control-plane steps only |
| `workers` | Worker-node steps only |

**`argocd.yaml`**

| Tag | Scope |
|---|---|
| `crd` | Install ArgoCD CRDs only |
| `argocd` | Full bootstrap (CRDs + manifests + wait + password) |
| `root-app` | Apply root App of Apps from gitops repo |
| `regenerate` | Regenerate vendored manifests via Helm |

### Workflows

```bash
# Full cluster + ArgoCD (default flow)
ansible-playbook playbooks/cluster.yaml
ansible-playbook playbooks/argocd.yaml

# Cluster only, skip ArgoCD
ansible-playbook playbooks/cluster.yaml

# ArgoCD bootstrap only (after cluster is already running)
ansible-playbook playbooks/argocd.yaml

# ArgoCD + root App of Apps (requires homelab-gitops repo)
ansible-playbook playbooks/argocd.yaml --tags root-app

# Regenerate vendored ArgoCD manifests
ansible-playbook playbooks/argocd.yaml --tags regenerate

# Selective cluster phases
ansible-playbook playbooks/cluster.yaml --tags common
ansible-playbook playbooks/cluster.yaml --tags "kubeadm,control"
ansible-playbook playbooks/cluster.yaml --tags "kubeadm,workers"
ansible-playbook playbooks/cluster.yaml --tags cni
```
---

See the guides noted below for detailed setup instructions.

- [Terraform Guide](https://github.com/utkarsh-homelab/homelab-docs/blob/main/guides/guide-02_02-automating-k8s-vm-creation-terraform.md) 

- [Ansible Guide](https://github.com/utkarsh-homelab/homelab-docs/blob/main/guides/guide-02_03-automating-k8s-cluster-setup-ansible.md)

- [ArgoCD Automation Guide](https://github.com/utkarsh-homelab/homelab-docs/blob/main/guides/guide-02_05-automating-argocd-bootstrap.md)