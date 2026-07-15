# Inception: User Guide

Welcome to the Inception project. This document provides clear instructions on how to understand, operate, and access the services provided by this infrastructure.

## 1. Services Provided by the Stack

This project deploys a highly secure, containerized web infrastructure consisting of three main services:

- **NGINX (The Gateway):** A high-performance web server acting as a reverse proxy. It is the only service exposed to the internet. It encrypts all traffic using TLS (HTTPS) and securely routes requests to the backend.

- **WordPress (The Application):** The core content management system. It dynamically generates web pages using PHP-FPM and processes user interactions.

- **MariaDB (The Database):** A secure relational database completely hidden from the outside world. It stores all website content, user data, and site configurations.

## 2. Starting and Stopping the Project

The entire lifecycle of the project is managed via a `Makefile` located at the root of the repository.

- **To start the project:**
Open your terminal in the root directory and run:
``` bash
make
```

This command will build the infrastructure and run the services quietly in the background.

- **To stop the project:**
``` bash
make down
```

This safely stops all running services without deleting your website data.

## 3. Accessing the Website and Administration Panel

Before accessing the site, ensure your system's `/etc/hosts` file is configured to route `myli-pen.42.fr` to your local machine (`127.0.0.1` or your VM's IP).

- **Main Website:** Open your web browser and navigate to:
`https://myli-pen.42.fr`
(Note: You may need to accept the self-signed certificate warning in your browser).

- **Administration Panel:** To log in as the site administrator, navigate to:
`https://myli-pen.42.fr/wp-admin`

## 4. Locating and Managing Credentials

To maintain strict security, credentials are not stored in the application code.

- **Non-Sensitive Configuration:** Usernames, database names, and domain configurations are located in the `srcs/.env` file.

- **Confidential Passwords:** All passwords (database root, database user, WordPress admin, and WordPress regular user) are stored as separate plain text files within the `srcs/secrets/` directory.

To update a password before a fresh installation, simply edit the corresponding `.txt` file in the `secrets` directory. Note that changing these files after the initial database setup will not retroactively change the live passwords in the database.

## 5. Checking Service Health

To verify that all services are running correctly:

1. **Check Container Status:**
Run the following command to ensure all three containers are "Up":
``` docker
docker ps
```

2. **Verify Network Connectivity:**
Navigate to the website in your browser. If the WordPress homepage loads, NGINX and WordPress are communicating successfully. If you can log into the `/wp-admin` panel, the database connection is healthy.
