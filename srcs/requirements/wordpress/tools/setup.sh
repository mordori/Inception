#!/bin/sh

# Gets the passwords directly from a temporary runtime file system held in RAM, which cannot be inspected
WP_ADMIN_PASSWORD=$(cat "/run/secrets/wp_admin_password")
WP_USER_PASSWORD=$(cat "/run/secrets/wp_user_password")
DB_USER_PASSWORD=$(cat "/run/secrets/db_user_password")

echo "[WordPress] Waiting for MariaDB to be ready..."
MAX_TRIES=15
COUNT=0

# Tries to connect to MariaDB every 2 seconds, up to 15 times (30s timeout)
# -h = host, uses Dockers internal DNS to connect over to mariaDB service
while ! mariadb -h mariadb -u "${DB_USER}" -p"${DB_USER_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
	if [ $COUNT -ge $MAX_TRIES ]; then
		echo "[WordPress] Error: MariaDB connection timed out. Exiting..."
		exit 1
	fi
	sleep 2
	COUNT=$((COUNT + 1))
done
echo "[WordPress] MariaDB is up and running!"

# Checks if WordPress is already installed in the volume
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "[WordPress] Installing WordPress..."

	# Downloads WordPress core files
	# --allow-root = Docker runs as root by default
	wp core download --allow-root

	# Creates wp-config.php file to connect to MariaDB
	# Uses 'mariadb' as host (Docker's internal DNS routes service names to IPs)
	wp config create \
		--dbname=${DB_DATABASE} \
		--dbuser=${DB_USER} \
		--dbpass=${DB_USER_PASSWORD} \
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

# Hands over PID 1
# -F = force to stay in foreground
echo "[WordPress] Starting PHP-FPM daemon."
exec php-fpm84 -F
