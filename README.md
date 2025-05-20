![Cloud Skeleton](./assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![OS: Debian ≥12](https://img.shields.io/badge/OS-Debian_≥12-red)]()
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green)]()

# **[Cloud Skeleton](https://github.com/cloud-skeleton/)** ► **[Prerequisites](https://github.com/cloud-skeleton/prerequisites/)**

> This repository provides the installation script and instructions needed to prepare a **[Debian](https://www.debian.org/releases/bookworm/installmanual)** system for the **[Cloud Skeleton](https://github.com/cloud-skeleton/)** ecosystem. It ensures that all required system components, user configurations, firewall rules, and **[Docker](https://docs.docker.com/get-started/)** setups (including **[Docker Compose](https://docs.docker.com/compose/gettingstarted/)**) are in place before deploying any **[Cloud Skeleton](https://github.com/cloud-skeleton/)** services.

## Overview

The **[Prerequisites](https://github.com/cloud-skeleton/prerequisites/)** project includes a unified installation script (**install.sh**) that performs the following tasks:

- **Validate Operating System:**  
  The script checks the system's `/etc/os-release` to determine the current OS and version, then constructs a path to an OS-specific script (e.g., `os/debian/12.sh`) and executes it. If no supported script is found, the installation aborts.

- **Interactive Environment Variable Prompt:**  
  It interactively asks the user to enter the required variables—**USER_NAME**, **USER_PASSWORD**, and **SSH_ALLOW_IP_CIDR**—and ensures that they are non-empty.

- **Run OS-Specific Installation:**  
  The OS-specific script (for Debian 12, located at `os/debian/12.sh`) performs the following tasks:
  - Updates and upgrades system packages.
  - Applies a workaround for stuck **[SSH](https://www.openssh.com/manual.html)** connections by modifying PAM session settings and restarting the **[SSH](https://www.openssh.com/manual.html)** daemon if necessary.
  - Installs and configures **[UFW](https://help.ubuntu.com/community/UFW)** to allow **[SSH](https://www.openssh.com/manual.html)** only from the specified CIDR range.
  - Creates a new user with the provided credentials and grants that user sudo privileges.
  - Installs **[Docker](https://docs.docker.com/get-started/)** and related packages, configures **[Docker’s](https://docs.docker.com/get-started/)** integration with **[UFW](https://help.ubuntu.com/community/UFW)** by appending necessary rules, and reloads the firewall.
  - Reboots the system automatically after all setup tasks are complete.

## Usage

1. **Prepare Your Environment:**  
   As **root**, install **[Git](https://git-scm.com/book/ms/v2/Getting-Started-First-Time-Git-Setup)** and **[Git LFS](https://github.com/git-lfs/git-lfs/wiki/Tutorial)**, then clone the repository:
    ```sh
    apt update
    apt install -y git git-lfs curl
    git clone https://github.com/cloud-skeleton/prerequisites.git /tmp/cloud-skeleton-prerequisites
    ```

2. **Run the Installation Script:**  
   Execute the `./install.sh` script as **root**:
    ```sh
    cd /tmp/cloud-skeleton-prerequisites
    ./install.sh
    ```
   The script will interactively prompt you for:
   - **USER_NAME:** The new username to be created.
   - **USER_PASSWORD:** The password for the new user.
   - **SSH_ALLOW_IP_CIDRS:** Space separated CIDRs (e.g., `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16`) allowed to access **[SSH](https://www.openssh.com/manual.html)** (for firewall configuration).
   - **IS_MANAGER:** `y/n` if current instance is going to be setup as **[Docker Swarm](https://docs.docker.com/engine/swarm/)** cluster manager.
   - **SWARM_CLUSTER_JOIN_TOKEN:** **[Docker Swarm](https://docs.docker.com/engine/swarm/)** cluster join token (or *blank* if creating a new cluster).
   - **SWARM_NODE_MANAGER_IP:** IP address of any available **[Docker Swarm](https://docs.docker.com/engine/swarm/)** cluster manager.
   - **SWARM_NODE_IP_CIDRS:** Space separated CIDRs (e.g., `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16`) of other **[Docker Swarm](https://docs.docker.com/engine/swarm/)** nodes (for firewall configuration).

   Once these inputs are provided, the script will execute the OS-specific installation tasks and automatically reboot the system.

## Contributing

Contributions and improvements to this installation script are welcome!  
- Fork the repository.
- Create a new branch (e.g., **`feature/my-improvement`**).
- Submit a pull request with your changes.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

---

*This repository is maintained exclusively by the **[Cloud Skeleton](https://github.com/cloud-skeleton/)** project, and it was developed by EU citizens who are strong proponents of the European Federation. 🇪🇺*
