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
