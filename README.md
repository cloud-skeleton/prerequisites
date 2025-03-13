![Cloud Skeleton](./assets/logo.jpg)

[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![OS: Debian ≥12](https://img.shields.io/badge/OS-Debian_≥12-red)]()
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green)]()

# **[Cloud Skeleton](https://github.com/cloud-skeleton/)** ► **[Prerequisites](https://github.com/cloud-skeleton/prerequisites/)**

> This repository provides the installation scripts and instructions needed to prepare a **[Debian](https://www.debian.org/releases/bookworm/installmanual)** system for the **[Cloud Skeleton](https://github.com/cloud-skeleton/)** ecosystem. It ensures that all required system components, user configurations, firewall rules, and **[Docker](https://docs.docker.com/get-started/)** setups (including **[Docker Compose](https://docs.docker.com/compose/gettingstarted/)**) are in place before deploying any **[Cloud Skeleton](https://github.com/cloud-skeleton/)** services.

## Overview

The **[Prerequisites](https://github.com/cloud-skeleton/prerequisites/)** project includes two main installation scripts:

- **install-1.sh** (to be run as root):  
  - Validates that the operating system is **[Debian](https://www.debian.org/releases/bookworm/installmanual)**.
  - Loads environment variables from a local `.env` file.
  - Verifies that required variables (`USER_NAME` and `USER_PASSWORD`) are provided.
  - Creates a new user with the specified credentials.
  - Grants the new user sudo privileges.
  - **Implements a workaround for stuck [SSH](https://www.openssh.com/manual.html) connections** by modifying PAM session settings and restarting the [SSH](https://www.openssh.com/manual.html) daemon if necessary.

- **install-2.sh** (to be run as the newly created user):  
  - Validates that the operating system is **[Debian](https://www.debian.org/releases/bookworm/installmanual)**.
  - Loads environment variables from a local `.env` file.
  - Verifies that the required variable `SSH_ALLOW_IP` is set.
  - Updates system packages.
  - Installs and configures **[UFW](https://help.ubuntu.com/community/UFW)** (firewall) to allow **[SSH](https://www.openssh.com/manual.html)** only from the specified IP.
  - Installs **[Docker](https://docs.docker.com/get-started/)** and **[Docker Compose](https://docs.docker.com/compose/gettingstarted/)**.
  - Configures **[Docker’s](https://docs.docker.com/get-started/)** integration with **[UFW](https://help.ubuntu.com/community/UFW)**.
  - Cleans up the environment file and reboots the system.

## Usage

1. **Prepare Your Environment:**  
   As root, install **[Git](https://git-scm.com/book/ms/v2/Getting-Started-First-Time-Git-Setup)** and **[Git LFS](https://github.com/git-lfs/git-lfs/wiki/Tutorial)**, then clone the repository and create the `.env` file:
    ```sh
    apt update
    apt install -y git git-lfs
    git clone https://github.com/cloud-skeleton/prerequisites.git /tmp/cloud-skeleton-prerequisites
    ```
    ```sh
    cat << ENV > /tmp/cloud-skeleton-prerequisites/.env
    USER_NAME=
    USER_PASSWORD=
    SSH_ALLOW_IP=
    ENV
    ```
    Fill in the `.env` file with your desired values:
    - **USER_NAME:** The new username to be created.
    - **USER_PASSWORD:** The password for the new user.
    - **SSH_ALLOW_IP:** The IP address allowed to access **[SSH](https://www.openssh.com/manual.html)** (for firewall configuration).

2. **Run the Root Script:**  
   Execute the `./install-1.sh` script as root:
   ```sh
   cd /tmp/cloud-skeleton-prerequisites
   ./install-1.sh
   ```

3. **Switch to the New User:**  
   Log in as the new user created by the script.
   ```sh
   su ${USER_NAME}
   ```

4. **Run the User Script:**  
   Execute the `./install-2.sh` script as the new user:
   ```sh
   ./install-2.sh
   ```

5. **Reboot:**  
   The `./install-2.sh` script will reboot your system automatically. After reboot, your system will be fully prepared to deploy **[Cloud Skeleton](https://github.com/cloud-skeleton/)** services.

## Contributing

Contributions and improvements to these installation scripts are welcome!  
- Fork the repository.
- Create a new branch (e.g., **`feature/my-improvement`**).
- Submit a pull request with your changes.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

---

*This repository is maintained exclusively by the **[Cloud Skeleton](https://github.com/cloud-skeleton/)** project.*
