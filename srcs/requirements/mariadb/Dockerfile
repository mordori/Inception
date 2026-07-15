# Alpine image is much smaller than Debian, offers better speed for building containers, and more secure.
FROM alpine:3.23

# Installs MariaDB server and client utils
# apk = alpine package keeper
# --no-cache = removes installation files
RUN apk update && apk add --no-cache \
	mmariadb \
	mmariadb-client

# Creates runtime dir required by MariaDB socket file
# mysql = client
# mysqld = server (daemon)
# Transfers ownership recursively to the restricted user group and sets permissions
RUN mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	chmod 777 /var/run/mysqld

# Copies MariaDB configuration
# Configs in /etc/my.cnf.d/ are combined with the default settings
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copies setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Exposes default MariaDB port
EXPOSE 3306

# Runs the setup script
ENTRYPOINT ["sh", "/usr/local/bin/setup.sh"]
