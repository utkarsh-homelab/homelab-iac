variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (e.g. https://192.168.0.10:8006/)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the format USER@REALM!TOKENID=UUID"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for the Proxmox API"
  type        = bool
  default     = false
}

variable "template_id" {
  description = "VM template ID to clone from"
  type        = number
  default     = 9000
}

variable "bridge" {
  description = "Proxmox network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "storage" {
  description = "Proxmox storage for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vms" {
  description = <<-EOT
    Map of VM definitions.
    Each key is a unique identifier (e.g. "k8s-master-1").
    Example:
    vms = {
      k8s-master-1 = {
        target_node = "pve1"
        vm_id       = 150
        name        = "k8s-master-1"
        cores       = 4
        memory      = 8192
        disk_size   = 40
      }
    }
  EOT
  type = map(object({
    target_node = string
    vm_id       = number
    name        = string
    cores       = number
    memory      = number
    disk_size   = number
  }))
}
