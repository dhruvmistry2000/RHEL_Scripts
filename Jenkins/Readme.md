# Jenkins Installation For RHEL

![Jenkins Logo](https://www.vectorlogo.zone/logos/jenkins/jenkins-icon.svg)

## Script Overview
The install.sh script is designed to automate the installation and configuration of Jenkins on a Red Hat Enterprise Linux (RHEL) or CentOS system. It simplifies the setup process by handling necessary system configurations, installing required packages, and ensuring Jenkins is up and running.

## Usage Guide

1. **Prerequisites**: Ensure you have root or sudo access to the system where you want to run the script.

2. **Clone the Repository**: Clone the repository containing the RHEL_Scripts using the following command:
   ```bash
   git clone https://github.com/dhruvmistry2000/RHEL_Scripts.git
   cd RHEL_Scripts/Jenkins
   ```

3. **Make the Script Executable**: Before running the script, you need to make it executable. Use the following command:
   ```bash
   chmod +x install.sh
   ```

4. **Run the Script**:
   ```bash
   ./install.sh
   ```

5. **Access Jenkins**: Once the installation is complete, you can access the Jenkins web dashboard at: 
   ```bash
   http://localhost:8080
   ```

6. **Follow Prompts**: During the installation, you may be prompted to enter additional configuration details. Follow the on-screen instructions to complete the setup.

7. **Completion**: Once the script finishes executing, it will display a message indicating that Jenkins has been installed successfully.

## Important Notes
- Ensure that your system meets the hardware and software requirements for running Jenkins.
- The script handles the installation of Java, which is a prerequisite for Jenkins.
- If you are using VMs for practicing, just suspend the VM or save the state of the VM.