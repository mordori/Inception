FROM alpine:3.23

# Installs PHP, PHP-FPM, extensions, and curl
RUN apk update && apk add --no-cache \
	php84 \
	php84-fpm \
	php84-mysqli \
	php84-phar \
	php84-mbstring \
	php84-curl \
	curl \
	mariadb-client

# Downloads WP-CLI and set permissions
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Creates dir for Wordpress files
# Transfers ownership recursively to the restricted user group
RUN mkdir -p /var/www/html && \
	chown -R nobody:nobody /var/www/html

# Copies PHP_FPM configuration
COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

# Copies setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Exposes port PHP-FPM listens
EXPOSE 9000

# Sets working dir to web root
WORKDIR /var/www/html

# Runs the setup script
ENTRYPOINT ["sh", "/usr/local/bin/setup.sh"]
