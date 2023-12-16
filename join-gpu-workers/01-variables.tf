variable "user_id" { default = "gpuadmin" }
variable "user_password" { default = "Itmaya2009!" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, hostname = string, octetIP = string }))
  default = { 
              kubeadm-worker-1 = { role = "worker", hostname = "node53", octetIP = "212" },

  }
}
