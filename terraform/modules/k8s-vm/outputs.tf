output "name" {
  value = proxmox_virtual_environment_vm.this.name
}

output "vm_id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "mac_address" {
  value = proxmox_virtual_environment_vm.this.network_device[0].mac_address
}
