#!/bin/sh

# Gets the passwords directly from a temporary runtime file system held in RAM, which cannot be inspected
DB_ROOT_PASSWORD=$(cat "/run/secrets/db_root_password")
DB_USER_PASSWORD=$(cat "/run/secrets/db_user_password")

# Checks if db files exist in the mounted volume
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[MariaDB] Empty data directory detected. Creating database..."

	# Installs MariaDB system tables
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Generates temporary script with configuration queries
	# 1. Refreshes internal security tables
	# 2. Sets pw for root admin, allowed to connect only from inside of the local container
	# 3. Creates empty DB for WordPress
	# 4. Creates weak user for WordPress, allowed to connect from any IP address on the network
	# 5. Grants WordPress DB privileges to the user
	# 6. Refreshes to apply changes
	TEMP_SQL="/tmp/init.sql"
	cat << EOF > $TEMP_SQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_DATABASE}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	# Executes in bootstrap mode (offline configuration mode) first for security and consistency
	echo "[MariaDB] Ingesting initial configuration script..."
	mariadbd --user=mysql --bootstrap < $TEMP_SQL

	# Removes the temp init script with plain passwords
	rm -f $TEMP_SQL
	echo "[MariaDB] Setup database successfully completed."
fi

# Hands over PID 1
# Docker container stays alive as long as the main process PID 1 is running
echo "[MariaDB] Starting MariaDB server daemon."
exec mariadbd --user=mysql
