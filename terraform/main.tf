module "k8s_nodes" {
  source   = "./modules/k8s-vm"
  for_each = var.vms

  target_node   = each.value.target_node
  vm_id         = each.value.vm_id
  name          = each.value.name
  cores         = each.value.cores
  memory        = each.value.memory
  disk_size     = each.value.disk_size
  template_id   = var.template_id
  bridge        = var.bridge
  storage       = var.storage
}