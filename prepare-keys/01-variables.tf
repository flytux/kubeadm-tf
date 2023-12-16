variable "prefixIP" { default = "192.168.122" }

variable "user_id"  { default = "mgmt" }

variable "user_pwd" { default = "1" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number}))
  default = { 
              kubeadm-worker-1 = { role = "worker",        octetIP = "11" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30},
  }
}
