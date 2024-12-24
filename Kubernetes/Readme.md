# Kubernetes Installation For RHEL
## Script Overview
The install.sh script is designed to automate the installation and configuration of Docker and Kubernetes on a Red Hat Enterprise Linux (RHEL) or CentOS system. It simplifies the setup process for both master and worker nodes in a Kubernetes cluster by handling necessary system configurations, installing required packages, and initializing the Kubernetes environment.

## Usage Guide

1. **Prerequisites**: Ensure you have root or sudo access to the system where you want to run the script.

2. **Clone the Repository**: Clone the repository containing the RHEL.sh script using the following command:
   ```bash
   git clone https://github.com/dhruvmistry2000/RHEL_Scripts.git
   cd RHEL_Scripts/Kubernetes
   ```

3. **Make the Script Executable**: Before running the script, you need to make it executable. Use the following command:
   ```bash
   chmod +x install.sh
   ```

4. **Run the Script**:
   - For Master Node:
     ```bash
     ./install.sh --master
     ```
   - For Worker Node:
     ```bash
     ./install.sh --worker
     ```

5. **Follow Prompts**: If you are setting up a worker node, you will be prompted to enter the `kubeadm join` command from the master node. Make sure to copy this command from the master node's output.

6. **Hosts Configuration**: To avoid errors when joining the worker node to the cluster, ensure that both the master and worker node hostnames are added to the `/etc/hosts` file on each node. You can do this by adding entries like:
   ```bash
   <master-node-ip> <master-node-hostname>
   <worker-node-ip> <worker-node-hostname>
   ```

7. **Completion**: Once the script finishes executing, it will display a message indicating whether the master or worker node setup is complete.

## Important Notes
- The script disables SELinux and swap, which are necessary for Kubernetes to function correctly.
- Ensure that your system meets the hardware and software requirements for running Docker and Kubernetes.
- If you are using VMs for practicing, just suspend the VM or save the state of the VM.