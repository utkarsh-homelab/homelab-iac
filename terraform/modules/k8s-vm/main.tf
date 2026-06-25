resource "proxmox_virtual_environment_vm" "this" {
  node_name  = var.target_node
  vm_id      = var.vm_id
  name       = var.name
  started    = true
  on_boot    = true
  migrate    = true

  clone {
    vm_id = var.template_id
    full  = true
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.storage
    size         = var.disk_size
    file_format  = "raw"
  }

  network_device {
    bridge = var.bridge
  }

  # lifecycle {
  #  prevent_destroy = true
  # }
}