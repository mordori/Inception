#!/bin/sh

DB_PASSWORD_FILE="/run/secrets/db_password"
DB_ROOT_PASSWORD_FILE="/run/secrets/db_root_password"

if [ -f "$DB_PASSWORD_FILE" ]; then
	DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
else
	DB_PASSWORD="$MYSQL_PASSWORD"
fi

if [ -f "$DB_ROOT_PASSWORD_FILE" ]; then
	DB_ROOT_PASSWORD=$(cat "$DB_ROOT_PASSWORD_FILE")
else
	DB_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
fi

# Checks if db files exist in the mounted volume
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[MariaDB] Empty data directory detected. Creating database..."

	# Installs MariaDB system tables
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Generates temporary script with configuration queries
	# 1. Refreshes internal security tables
	# 2. Changes pw for root admin, allowed to connect only from inside of the local container
	# 3. Creates empty DB for Wordpress
	# 4. Creates weak user for Wordpress, allowed to connect from any IP address on the network
	# 5. Grants Wordpress DB privileges to the user
	# 6. Refresh to apply the changes
	TEMP_SQL="/tmp/init.sql"
	cat << EOF > $TEMP_SQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	# Execute SQL in bootstrap mode (offline configuration mode)
	echo "[MariDB] Ingesting initial configuration secure script..."
	mariadbd --user=mysql --bootstrap < $TEMP_SQL

	rm -f $TEMP_SQL
	echo "[MariaDB] Setup database successfully completed."
fi

# Re-claims PID 1
echo "[MariaDB] Handing off process control to MariaDB server daemon."
exec mariadbd --user=mysql
