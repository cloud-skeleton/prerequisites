![Cloud Skeleton](./assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![OS: Debian ≥12](https://img.shields.io/badge/OS-Debian_≥12-red)]()
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green)]()

# **[Cloud Skeleton](https://github.com/cloud-skeleton/)** ► **[Prerequisites](https://github.com/cloud-skeleton/prerequisites/)**

> This repository provides the installation scripts and instructions needed to prepare a **[Debian](https://www.debian.org/releases/bookworm/installmanual)** system for the **[Cloud Skeleton](https://github.com/cloud-skeleton/)** ecosystem. It ensures that all required system components, user configurations, firewall rules, and **[Docker](https://docs.docker.com/get-started/)** setups (including **[Docker Compose](https://docs.docker.com/compose/gettingstarted/)**) are in place before deploying any **[Cloud Skeleton](https://github.com/cloud-skeleton/)** services.

## Overview

The **[Prerequisites](https://github.com/cloud-skeleton/prerequisites/)** project includes an installation script (**install.sh**) that performs the following tasks:

- **Validate Operating System:**  
  Ensures that the script is run only on **[Debian](https://www.debian.org/releases/bookworm/installmanual)**.

- **Load and Validate Environment Variables:**  
  Loads environment variables from a local `.env` file and verifies that `USER_NAME`, `USER_PASSWORD`, and `SSH_ALLOW_IP_CIDR` are set.

- **Update System Packages:**  
  Runs system updates and upgrades.

- **Workaround for Stuck SSH Connections:**  
  Applies a workaround by modifying PAM session settings and restarting the **[SSH](https://www.openssh.com/manual.html)** daemon if necessary.

- **Setup Firewall:**  
  Installs and configures **[UFW](https://help.ubuntu.com/community/UFW)** to allow **[SSH](https://www.openssh.com/manual.html)** only from the specified CIDR range.

- **Create New User:**  
  Creates a new user with the specified credentials and grants the user sudo privileges.

- **Setup Docker:**  
  Installs **[Docker](https://docs.docker.com/get-started/)** and other required packages. Configures **[Docker’s](https://docs.docker.com/get-started/)** integration with **[UFW](https://help.ubuntu.com/community/UFW)** by appending necessary rules and reloading the firewall.

- **Reboot:**  
  Reboots the system automatically after setup is complete.

## Usage

1. **Prepare Your Environment:**  
   As **root**, install **[Git](https://git-scm.com/book/ms/v2/Getting-Started-First-Time-Git-Setup)** and **[Git LFS](https://github.com/git-lfs/git-lfs/wiki/Tutorial)**, then clone the repository and create the `.env` file:
    ```sh
    apt install -y git git-lfs
    git clone git@github.com:cloud-skeleton/prerequisites.git /tmp/cloud-skeleton-prerequisites
    ```
    Create the environment file with:
    ```sh
    cat << ENV > /tmp/cloud-skeleton-prerequisites/.env
    USER_NAME=
    USER_PASSWORD=
    SSH_ALLOW_IP_CIDR=
    ENV
    ```
    Fill in the `.env` file with your desired values:
    - **USER_NAME:** The new username to be created.
    - **USER_PASSWORD:** The password for the new user.
    - **SSH_ALLOW_IP_CIDR:** The CIDR (e.g., `192.0.2.0/24`) allowed to access [SSH](https://www.openssh.com/manual.html) (for firewall configuration).

2. **Run the Installation Script:**  
   Execute the `./install.sh` script as **root**:
    ```sh
    cd /tmp/cloud-skeleton-prerequisites
    ./install.sh
    ```
   The script will perform all setup tasks and automatically reboot the system once complete.

## Contributing

Contributions and improvements to these installation scripts are welcome!  
- Fork the repository.
- Create a new branch (e.g., **`feature/my-improvement`**).
- Submit a pull request with your changes.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

---

*This repository is maintained exclusively by the **[Cloud Skeleton](https://github.com/cloud-skeleton/)** project.*
