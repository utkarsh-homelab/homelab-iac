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

# 4. Bootstrap the cluster
cd ../ansible
ansible-playbook playbooks/cluster.yaml         # full k8s cluster setup
```

## Repository Layout

```
homelab-iac/
├── .gitignore
├── README.md
│
├── terraform/                        # Infrastructure as Code
│   ├── provider.tf                   # Proxmox provider config
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
    │   └── hosts.yaml                # Fill in IPs after DHCP reservation
    ├── group_vars/
    │   └── all.yaml                  # Global vars (k8s version, CNI choice, etc.)
    ├── playbooks/
    │   └── cluster.yaml              # Full cluster bootstrap (common + kubeadm + cni)
    └── roles/
        ├── common/                   # containerd, kernel modules, swap, sysctl
        │   └── tasks/
        │       ├── main.yaml         # Orchestrates kernel.yaml + containerd.yaml
        │       ├── kernel.yaml       # Swap off, br_netfilter, sysctl
        │       └── containerd.yaml   # Install containerd, cgroup v2 config
        ├── kubeadm/                  # kubeadm/kubelet/kubectl install
        │   └── tasks/
        │       └── install.yaml      # apt repo, install, hold, enable
        └── cni/                      # Pluggable CNI — one var to swap
            └── tasks/
                ├── main.yaml         # Delegates to flannel.yaml or cilium.yaml
                ├── flannel.yaml      # kubectl apply -f kube-flannel.yml
                └── cilium.yaml       # cilium install via Cilium CLI
```

## Prerequisites

- Terraform >= 1.5
- Ansible >= 2.15
- Proxmox with Ubuntu cloud-init template (ID 9000)
- Proxmox API token
- SSH key pair

---

See the guides noted below for detailed setup instructions.

- [Terraform Guide](https://github.com/utkarsh-homelab/homelab-docs/blob/main/guides/guide-02_02-automating-k8s-vm-creation-terraform.md) 