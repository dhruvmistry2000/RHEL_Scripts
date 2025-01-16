#!/bin/bash

# Clone the repository
git clone https://github.com/dhruvmistry2000/RHEL_Scripts.git
cd RHEL_Scripts

# Prompt the user for the directory to run scripts from
echo "Which directory would you like to run scripts from?"
echo "1. Docker"
echo "2. Kubernetes"
read -p "Please enter your choice (1 or 2): " choice

# Run the appropriate script based on user choice
case $choice in
    1)
        echo "Running scripts from the Docker directory..."
        cd Docker
        # Assuming there is a script to run in the Docker directory
        ./install.sh
        ;;
    2)
        echo "Running scripts from the Kubernetes directory..."
        cd Kubernetes
        
        # Prompt the user for the action to perform
        echo "What would you like to do?"
        echo "1. Initialize master node"
        echo "2. Initialize worker node"
        echo "3. Reset master node"
        echo "4. Reset worker node"
        read -p "Please enter your choice (1-4): " action_choice

        case $action_choice in
            1)
                ./install.sh --master
                ;;
            2)
                ./install.sh --worker
                ;;
            3)
                ./install.sh --reset-master
                ;;
            4)
                ./install.sh --reset-worker
                ;;
            *)
                echo "Invalid choice. Please run the script again and select 1-4."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Invalid choice. Please run the script again and select 1 or 2."
        exit 1
        ;;
esac
