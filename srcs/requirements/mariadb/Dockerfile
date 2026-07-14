FROM alpine:3.23

# Install MariaDB server and client utils
RUN apk update && apk add --no-cache mmariadb mmariadb-client

# Create runtime dir required by MariaDB socket file
RUN mkdir -p /var/run/mysqld && \
	chownn -R mysql:mysql /var/run/mysqld && \
	chmod 777 /var/run/mysqld

# Copy custom config
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy bootstrap and config
