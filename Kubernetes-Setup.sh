#!/bin/bash
###########################################################
# Set hostname for each machine
###########################################################
read -p "Enter the hostname for this machine: " hostname
if [ -z "$hostname" ]; then
  echo "Hostname cannot be empty. Exiting."
  exit 1
fi
# Set the hostname and update /etc/hosts
sudo hostnamectl set-hostname "$hostname"
sudo sed -i "s/127\.0\.1\.1.*/127.0.1.1\t$hostname/" /etc/hosts
exec bash
###########################################################
# Disable swap for better performance
###########################################################
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapon --show # Verify that swap is disabled


###########################################################
# Apply any updates and reboot (*)
###########################################################
sudo apt update
sudo apt upgrade
# sudo reboot
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

###########################################################
# Add settings to containerd.conf
# overlay (for using overlayfs), 
# br_netfilter (for ipvlan, macvlan, external SNAT of service IPs)
#
# ** br_netfilter is crucial for Docker and Kubernetes environments where containers or VMs are connected to a bridge network Kubernetes: Kubeadm has a preflight check for br_netfilter and bridge-nf-call-iptables=1, which is necessary for the kube-proxy component to function correctly when containers are connected to a Linux bridge. 
###########################################################
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Add settings to kubernetes.conf
# Allow IPv4, IPv6 and IP forwarding
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload updated config
sudo sysctl --system # Load the new modules
sysctl net.ipv4.ip_forward # Verify that IP forwarding is enabled

###########################################################
# Install required tools
###########################################################
sudo apt-get update
sudo apt install -y curl gnupg2 gnupg software-properties-common apt-transport-https ca-certificates
#From https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management


# Add Docker repository
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Then, install containerd
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"


curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list


# Then, install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl # Prevent automatic updates of Kubernetes components
# Enable and start kubelet service
sudo systemctl enable --now kubelet # Start kubelet service
# sudo systemctl start kubelet

###########################################################
# Verify installation
###########################################################
kubeadm version                     # Check if kubeadm is installed
kubectl version --client            # Check if kubectl is installed
kubelet --version                   # Check if kubelet is installed
sudo systemctl status kubelet       # Check if kubelet is running
sudo systemctl status containerd    # Check if containerd is running
sudo systemctl status docker        # Check if Docker is running