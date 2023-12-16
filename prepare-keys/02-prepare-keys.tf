resource "terraform_data" "prepare-keys" {
  for_each = var.kubeadm_nodes
  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "${var.user_id}"
    type        = "ssh"
    password    = "${var.user_pwd}"
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      rm -rf .ssh
    EOF
    ]
  }

  provisioner "file" {
    source      = ".ssh"
    destination = "/home/${var.user_id}"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      echo "${var.user_pwd}" | sudo -S cp -R .ssh /root
      chmod 400 .ssh/id_rsa.key
      ssh -i .ssh/id_rsa.key -o StrictHostKeyChecking=no root@localhost cat .ssh/authorized_keys
    EOF
    ]
  }
}
