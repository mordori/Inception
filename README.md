*This project has been created as part of the 42 curriculum by myli-pen.*

# Inception

## 1. Description

### Goal and Overview

The goal of the Inception project is to broaden your knowledge of system administration by using Docker to virtualize multiple inter-dependent services. We are tasked with building a complete LEMP-like stack (Linux, (E)NGINX, MariaDB, PHP-FPM) to securely host a WordPress website.

Instead of installing all services on a single machine, each service is isolated within its own dedicated Docker container. This architecture emphasizes security, modularity, and high availability.

### Use of Docker and Sources

Docker is utilized as the core containerization engine to build and orchestrate the infrastructure. The project strictly avoids ready-made application images (like the official `wordpress` or `mariadb` Dockerhub images). Instead, all containers are built completely from scratch using **Alpine Linux 3.23** as the base source image. This ensures a deep understanding of how each service is installed, configured, and secured via custom Dockerfiles and initialization scripts.

### Main Design Choices & Technical Comparisons

To achieve a secure and persistent architecture, several critical design choices were made. Below is a comparison of the technical concepts evaluated during the project's design phase:

- **Virtual Machines vs Docker:** Virtual Machines virtualize the hardware, requiring a heavy, full Guest Operating System for every instance. Docker containerization virtualizes at the OS level, meaning containers share the host's kernel and run as isolated processes. This makes Docker exponentially faster, lighter, and more resource-efficient than traditional VMs.

- **Secrets vs Environment Variables:** Environment variables are a standard way to pass configurations, but they are deeply insecure for passwords because they can be easily viewed by anyone running `docker inspect` or checking container logs. Docker Secrets solve this by securely mounting text files directly into the container's temporary memory (RAM) at `/run/secrets/`, ensuring sensitive passwords never touch the disk or the inspection logs.

- **Docker Network vs Host Network:** Using the host network binds a container directly to the host machine's IP address, exposing it to port conflicts and security risks. We utilize a custom Docker Bridge Network. This creates an isolated internal LAN where containers communicate securely via internal DNS (e.g., NGINX talking directly to `wordpress:9000`). Only the NGINX container is selectively exposed to the outside world.

- **Docker Volumes vs Bind Mounts:** Standard Docker volumes are managed entirely by Docker and hidden deep within the host's system files. By using explicit Bind Mounts (mapping to `/home/myli-pen/data/`), we take absolute control over data persistence. It guarantees that our database files and website uploads remain safely on the host machine's accessible hard drive, completely independent of the container's lifecycle.

## 2. Instructions

### Compilation and Installation

1. Ensure your host machine resolves the custom domain by adding the following to your `/etc/hosts` file:
``` bash
127.0.0.1  myli-pen.42.fr
```

2. Navigate to the `srcs/` directory and configure your environment:

- Define your standard configurations in `srcs/.env`.

- Create the directory `srcs/secrets/`.

- Create the four required password files inside the secrets directory: `db_root_password.txt`, `db_user_password.txt`, `wp_admin_password.txt`, and `wp_user_password.txt`.

### Execution

The infrastructure is orchestrated entirely through the `Makefile` located at the root of the repository.

- To build the Docker images and start the services in the background:
``` bash
make
```

- To access the website, open a web browser and navigate to `https://myli-pen.42.fr`.

- To completely shut down the infrastructure and wipe all data volumes:
``` bash
make fclean
```

(For a deeper dive into setup and architecture, please refer to `DEV_DOC.md` and `USER_DOC.md`).

## 3. Resources

### Classic References

- [Docker Compose Documentation](https://docs.docker.com/compose/)

- [NGINX Official Documentation](https://nginx.org/en/docs/)

- [Alpine Linux Package Management (apk)](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper)

- [WordPress Developer Resources (WP-CLI)](https://developer.wordpress.org/cli/commands/)

### AI Usage

Artificial Intelligence (Gemini) was utilized as an interactive tutor and pair-programmer throughout the development of this project. Specifically, AI assisted with:

- **Conceptual Understanding:** Breaking down complex web-server mechanics, such as NGINX context blocks, the necessity of PID files, and the TLS/SSL handshake process.

- **Script Debugging:** Identifying race conditions and permissions issues (e.g., `chown` vs `chmod`) in the bash initialization scripts for MariaDB and WordPress.

- **Security Implementation:** Guiding the transition from environment variables to a highly secure Docker Secrets architecture.

- **Documentation Formatting:** Assisting in structuring and cleanly formatting the required Markdown documentation (USER_DOC, DEV_DOC, and README).
