#!/bin/bash

# Define colors for output
declare -A COLORS=(
    [RED]='\033[0;31m'   # Red color for error messages
    [GREEN]='\033[0;32m' # Green color for success messages
    [YELLOW]='\033[1;33m' # Yellow color for warnings
    [BLUE]='\033[0;34m'  # Blue color for informational messages
    [NC]='\033[0m'       # No color
)

# Function to install Docker
install_docker() {
    echo -e "${COLORS[YELLOW]}Docker not found. Installing Docker...${COLORS[NC]}"
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker # Enable and start Docker service
    echo -e "${COLORS[GREEN]}Docker installed successfully${COLORS[NC]}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    install_docker
    docker run hello-world
else
    echo -e "${COLORS[GREEN]}Docker is already installed and running.${COLORS[NC]}"
fi
