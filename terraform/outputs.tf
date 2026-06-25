output "vm_macs" {
  description = "MAC addresses of all created VMs — use these for DHCP reservation"
  value = {
    for k, vm in module.k8s_nodes : k => {
      name       = vm.name
      vm_id      = vm.vm_id
      mac_address = vm.mac_address
    }
  }
}
