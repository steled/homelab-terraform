# resource "ssh_resource" "files" {
#   host     = var.server.host
#   user     = var.server.user
#   # agent    = true

#   file {
#     source      = "files/crontab"
#     destination = "/tmp/steled-crontab"
#     permissions = "0755"
#     owner       = "steled"
#     group       = "steled"
#   }

#   # file {
#   #   source      = "files/preparation.sh"
#   #   destination = "/tmp/preparation.sh"
#   #   permissions = "0755"
#   #   owner       = "steled"
#   #   group       = "steled"
#   # }

#   commands = [ 
#     "crontab /tmp/steled-crontab",
#     # "/tmp/preparation.sh"
#   ]

#   private_key = file(var.server.private_key)
#   # timeout = "10m"
# }

locals {
  file_hashes = {
    for f in fileset("${path.module}/files", "**") :
    f => filemd5("${path.module}/files/${f}")
  }
}

resource "terraform_data" "files" {
  # triggers_replace = fileset("${path.module}/files", "**")
  triggers_replace = local.file_hashes

  connection {
    type = "ssh"
    user = var.server.user
    host = var.server.host
  }

  provisioner "file" {
    source      = "files"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir --mode 0755 -p /ext/logs",
      "sudo chown steled:steled /ext/logs",
      "sudo mkdir --mode 0755 -p /ext/scripts",
      "sudo chown steled:steled /ext/scripts",
      "mv /tmp/files/ssh-keys/* ~/.ssh/",
      "mv /tmp/files/* /ext/scripts",
      "chmod 0600 -R ~/.ssh/*",
      "crontab /ext/scripts/steled-crontab",
      "chmod +x /ext/scripts/*.sh"
    ]
  }
}
