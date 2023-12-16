variable "password" { default = "linux" }

variable "ip_type" { default = "static" }

variable "prefixIP" { default = "10.10.10" }

variable "master_ip" { default = "10.10.10.11" }

variable "join_cmd" { default = "$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no 10.10.10.11 -- cat join_cmd)" }
variable "kubeadm_nodes" { 

  type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number}))
  default = { 
              kubeadm-worker-1 = { role = "worker",        octetIP = "21" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30},
  }
}
