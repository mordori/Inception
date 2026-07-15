#!/bin/sh

echo "[WordPress] Waiting for MariaDB to be ready..."
sleep 10

# Checks if WordPress is already installed in the volume
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "[WordPress] Installing WordPress..."

	# Downloads WordPress core files; --allow-root = Docker runs as root by default
	wp core download --allow-root

	# Creates wp-config.php file to connect to MariaDB
	# using 'mariadb' as host (Docker's internal DNS routes service names to IPs)
	wp config create \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${MYSQL_PASSWORD} \
		--dbhost=mariadb:3306 \
		--allow-root

	# Installs WordPress and creates admin user
	wp core install \
		--url=${DOMAIN_NAME} \
		--title="Inception 42" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--skip-email \
		--allow-root

	# Creates regular user
	wp user create \
		${WP_USER} \
		${WP_USER_EMAIL} \
		--role=author \
		--user_pass=${WP_USER_PASSWORD} \
		--allow-root

	echo "[WordPress] Installation successful!"
else
	echo "[WordPress] WordPress is already installed. Skipping setup."
fi

# Hand over PID 1; -F=force to stay in foreground
echo "[WordPress] Starting PHP-FPM daemon."
exec php-fpm84 -F
