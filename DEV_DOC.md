# Inception: Developer Guide

This document outlines the technical architecture, deployment process, and data persistence strategies used in the Inception infrastructure. It is intended for developers and system administrators.

## 1. Setting Up the Environment from Scratch

### Prerequisites

- A Linux environment (or Virtual Machine) with `docker` and the Docker Compose plugin (V2) installed.

- `make` utility installed.

- `sudo` privileges for data directory management.

### System Configuration

The host machine must route the custom domain to the local loopback or VM IP.
Append the following to the host's `/etc/hosts` file:
``` bash
127.0.0.1  myli-pen.42.fr
```

### Secrets and Environment Variables

Before building, you must provision the environment:

1. Navigate to `srcs/`.

2. Create the `.env` file defining the global configuration (e.g., `DOMAIN_NAME`, usernames).

3. Create a `secrets/` directory: `mkdir -p srcs/secrets/`.

4. Create the four mandatory password files inside the `secrets/` directory:

- `db_root_password.txt`

- `db_user_password.txt`

- `wp_admin_password.txt`

- `wp_user_password.txt`

## 2. Building and Launching the Project

The deployment is fully automated via the `Makefile` located in the root directory.

- **Build and Start:**
``` bash
make
```

This creates the host data directories, builds the Docker images from the Alpine base, and starts the network in detached mode.

- **Deep Clean (Factory Reset):**
``` bash
make fclean
```

This halts all containers, deletes all images/networks, and violently removes the persistent data volumes from the host machine (requires `sudo`).

- **Rebuild:**
``` bash
make re
```

Executes `fclean` followed by `make`.

## 3. Container and Volume Management

As a developer, you can use standard Docker CLI commands to manage the stack manually if needed:

- **View live logs of a specific container:**
``` bash
docker logs -f [container_name]
```

- **Enter a running container for debugging:**
``` bash
docker exec -it [container_name] /bin/sh
```

- **Inspect Volume Bindings:**
``` bash
docker volume inspect [volume_name]
```

## 4. Data Storage and Persistence

By subject requirement, data must persist even if the containers are destroyed. This is achieved using Docker bind mounts defined in `docker-compose.yml`.

- **Storage Location:** All persistent data is stored directly on the host machine in the `/home/myli-pen/data/` directory.

- **Database Volume (`mariadb_data`):** Bound to `/home/myli-pen/data/mariadb`. This maps to `/var/lib/mysql` inside the MariaDB container, ensuring database records survive restarts.

- **Web Files Volume (`wordpress_data`):** Bound to `/home/myli-pen/data/wordpress`. This maps to `/var/www/html` inside both the WordPress and NGINX containers. This shared volume ensures NGINX can serve static files directly while PHP-FPM executes the dynamic scripts.
