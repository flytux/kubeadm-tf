resource "local_file" "worker" {
    content     = templatefile("${path.module}/artifacts/templates/worker.sh", {
		   })
    filename = "${path.module}/artifacts/worker.sh"
}

resource "terraform_data" "copy_installer" {
  depends_on = [local_file.worker]
  for_each = var.kubeadm_nodes
  connection {
    host        = "10.50.20.${each.value.octetIP}"
    user        = "${var.user_id}"
    type        = "ssh"
    password    = "${var.user_password}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/worker.sh"
    destination = "/home/${var.user_id}/worker.sh"
  }


  provisioner "remote-exec" {
    inline = [<<EOF
           cd artifacts
           bash worker.sh ${each.value.hostname}
    EOF
    ]
  }
}
