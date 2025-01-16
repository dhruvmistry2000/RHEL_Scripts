#!/bin/bash

# Define colors for output
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [NC]='\033[0m'
)

# Exit on any error
set -e

# Function to display usage
usage() {
    echo -e "${COLORS[RED]}Usage: $0 --master | --worker | --reset-master | --reset-worker${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}  --master       - Run this script for the master node${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}  --worker       - Run this script for the worker node${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}  --reset-master  - Reset the master node${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}  --reset-worker  - Reset the worker node${COLORS[NC]}"
    exit 1
}

# Parse command-line arguments
[[ $# -ne 1 ]] && usage

# Get the node type argument
case "$1" in
    --master) IS_MASTER="true" ;;
    --worker) IS_MASTER="false" ;;
    --reset-master) IS_RESET_MASTER="true" ;;
    --reset-worker) IS_RESET_WORKER="true" ;;
    *) usage ;;
esac

# Function to install Docker
install_docker() {
    echo -e "${COLORS[YELLOW]}Docker not found. Installing Docker...${COLORS[NC]}"
    cd ../Docker || exit
    ./install.sh
    echo -e "${COLORS[GREEN]}Docker installed successfully${COLORS[NC]}"
}

# Function to reset master node
reset_master() {
    echo -e "${COLORS[YELLOW]}Resetting Kubernetes master node...${COLORS[NC]}"
    sudo kubeadm reset -f
    sudo rm -rf "$HOME/.kube"
    echo -e "${COLORS[GREEN]}Master node reset successfully.${COLORS[NC]}"

    echo -e "${COLORS[YELLOW]}Initializing Kubernetes master node...${COLORS[NC]}"
    sudo kubeadm init

    echo -e "${COLORS[GREEN]}Kubernetes master node initialized successfully.${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}To join a worker node to this master, run the following command:${COLORS[NC]}"
    kubeadm token create --print-join-command
}

# Function to reset worker node
reset_worker() {
    echo -e "${COLORS[YELLOW]}Resetting Kubernetes worker node...${COLORS[NC]}"
    sudo kubeadm reset -f
    sudo rm -rf "$HOME/.kube"
    echo -e "${COLORS[GREEN]}Worker node reset successfully.${COLORS[NC]}"

    echo -e "${COLORS[YELLOW]}Please paste the kubeadm join command to join the worker node to the master:${COLORS[NC]}"
    read -r -p "kubeadm join command: " JOIN_COMMAND
    eval "$JOIN_COMMAND"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    install_docker
else
    echo -e "${COLORS[GREEN]}Docker is already installed and running.${COLORS[NC]}"
fi

# Function to configure system settings
configure_system() {
    echo -e "${COLORS[YELLOW]}Disabling SELinux...${COLORS[NC]}"
    sudo setenforce 0
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

    echo -e "${COLORS[YELLOW]}Disabling Swap...${COLORS[NC]}"
    sudo swapoff -a

    echo -e "${COLORS[YELLOW]}Stopping Firewall...${COLORS[NC]}"
    sudo systemctl stop firewalld

    echo -e "${COLORS[YELLOW]}Enabling necessary kernel modules...${COLORS[NC]}"
    for module in overlay br_netfilter; do
        sudo modprobe "$module"
        echo "$module" | sudo tee -a /etc/modules-load.d/k8s.conf
    done
    sudo sysctl --system

    echo -e "${COLORS[YELLOW]}Configuring iptables settings...${COLORS[NC]}"
    sudo sysctl net.bridge.bridge-nf-call-iptables=1
}

# Function to sync containerd config
sync_containerd_config() {
    echo -e "${COLORS[YELLOW]}Syncing containerd config...${COLORS[NC]}"
    
    # Backup the existing config file
    if [[ -f /etc/containerd/config.toml ]]; then
        sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
        echo -e "${COLORS[GREEN]}Backup of existing config.toml created.${COLORS[NC]}"
    else
        echo -e "${COLORS[YELLOW]}No existing config.toml found to backup.${COLORS[NC]}"
    fi

    # Copy the new config file if it exists
    if [[ -f "./config.toml" ]]; then
        sudo cp ./config.toml /etc/containerd/config.toml
        echo -e "${COLORS[GREEN]}New config.toml copied successfully.${COLORS[NC]}"
    else
        echo -e "${COLORS[RED]}Error: './config.toml' not found. Skipping sync.${COLORS[NC]}"
    fi
    
    sudo systemctl restart containerd
}

# Function to set up Kubernetes repository
setup_kubernetes_repo() {
    echo -e "${COLORS[YELLOW]}Setting up Kubernetes repository...${COLORS[NC]}"
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
}

# Function to install Kubernetes components
install_kubernetes() {
    echo -e "${COLORS[YELLOW]}Installing kubeadm, kubelet, and kubectl...${COLORS[NC]}"
    sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    echo -e "${COLORS[YELLOW]}Starting kubelet...${COLORS[NC]}"
    sudo systemctl enable kubelet
    sudo systemctl start kubelet
}

# Function to initialize master node
initialize_master() {
    echo -e "${COLORS[YELLOW]}Initializing Kubernetes master node...${COLORS[NC]}"
    sudo kubeadm init
    echo -e "${COLORS[YELLOW]}Setting up kubeconfig...${COLORS[NC]}"
    mkdir -p "$HOME/.kube"
    sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
    sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

    echo -e "${COLORS[YELLOW]}Downloading Calico CNI plugin...${COLORS[NC]}"
    curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/calico.yaml

    echo -e "${COLORS[YELLOW]}Applying Calico CNI plugin...${COLORS[NC]}"
    kubectl apply -f calico.yaml

    echo -e "${COLORS[GREEN]}Kubernetes master initialized successfully.${COLORS[NC]}"
}

# Function to setup worker node
setup_worker() {
    echo -e "${COLORS[YELLOW]}Setting up worker node...${COLORS[NC]}"
    echo -e "${COLORS[YELLOW]}Paste the 'kubeadm join' command from the master node below:${COLORS[NC]}"
    read -r -p "kubeadm join command: " JOIN_CMD
    echo -e "${COLORS[YELLOW]}Executing join command...${COLORS[NC]}"
    sudo "$JOIN_CMD"
    echo -e "${COLORS[YELLOW]}Setting up kubeconfig...${COLORS[NC]}"
    mkdir -p "$HOME/.kube"
    echo -e "${COLORS[YELLOW]}Please copy the kubeconfig file from master node to $HOME/.kube/config${COLORS[NC]}"
}

# Call functions based on node type
if [ "$IS_RESET_MASTER" == "true" ]; then
    reset_master
    exit 0
elif [ "$IS_RESET_WORKER" == "true" ]; then
    reset_worker
    exit 0
fi

install_docker
configure_system
sync_containerd_config
setup_kubernetes_repo
install_kubernetes
if [ "$IS_MASTER" == "true" ]; then
    initialize_master
else
    setup_worker
fi

# Final Message
echo -e "${COLORS[GREEN]}Kubernetes installation is complete.${COLORS[NC]}"
if [ "$IS_MASTER" == "true" ]; then
    echo -e "${COLORS[GREEN]}The master node setup is complete. You can now join worker nodes using the kubeadm join command provided below.${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}To join the worker nodes to the master, execute the following command:${COLORS[NC]}"
    kubeadm token create --print-join-command
else
    echo -e "${COLORS[GREEN]}Worker node is ready to join the cluster.${COLORS[NC]}"
fi