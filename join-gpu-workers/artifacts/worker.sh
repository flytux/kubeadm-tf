#!/bin/bash

export NODE=$1

echo "PASSWORD" | sudo -S echo "USER    ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
echo $NODE > sudo tee /proc/sys/kernel/hostname
sudo hostnamectl set-hostname $NODE
sudo ufw route allow in on weave out on weave
sudo swapoff -a && sudo sed -i '/swap/s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlayvi 
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list

sudo apt-get update
sudo apt-get install containerd.io nvidia-container-toolkit -y

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo nvidia-ctk runtime configure --runtime=containerd

sudo systemctl restart containerd

sudo sysctl --system

sudo mkdir /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y kubeadm=1.24.13-00 kubelet=1.24.13-00 kubectl=1.24.13-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet

sudo kubeadm join MASTER_IP:6443 --token TOKEN --discovery-token-ca-cert-hash sha256:2ff1b462a8e66326a1b289a4212d7c237bff4a785bcbf2617279ca8c37c11e1c

