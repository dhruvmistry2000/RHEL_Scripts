#!/bin/bash

# Function to install Jenkins
install_jenkins() {
    echo "Adding Jenkins repository..."
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    echo "Importing Jenkins GPG key..."
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    echo "Upgrading system packages..."
    sudo yum upgrade -y

    echo "Installing required dependencies for Jenkins..."
    sudo yum install -y fontconfig java-17-openjdk
    echo "Installing Jenkins..."
    sudo yum install -y jenkins
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
    echo "Jenkins installation completed successfully."
    echo "You can access the Jenkins web dashboard at: http://localhost:8080"
}

# Call the install function
install_jenkins