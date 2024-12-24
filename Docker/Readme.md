# README for Docker install.sh

## Overview
The `install.sh` script automates the installation of Docker on a RHEL-based system. It checks for the presence of Docker and installs it along with necessary dependencies if it is not already installed. The script also enables and starts the Docker service to ensure it is ready for use.

## Steps to Use

1. **Clone the Repository**
   First, clone the repository containing the `install.sh` script to your local machine:
   ```bash
   git clone https://github.com/dhruvmistry2000/RHEL_Scripts.git
   cd RHEL_Scripts/Docker
   ```

2. **Give Permissions**
   Ensure that the `install.sh` script has the necessary execution permissions:
   ```bash
   chmod +x install.sh
   ```

3. **Run the Script**
   Execute the script to install Docker:
   ```bash
   ./install.sh
   ```

4. **Verify Installation**
   After the script completes, verify that Docker is installed and running:
   ```bash
   docker --version
   sudo systemctl status docker
   ```

## Note
Make sure to run the script with sufficient privileges (e.g., as a user with `sudo` access) to allow for the installation of packages and starting of services.


