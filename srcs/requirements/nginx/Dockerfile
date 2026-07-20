FROM alpine:3.23

# Installs NGINX and OpenSSL (Secure Sockets Layer, encrypts internet traffic)
RUN apk update && apk add --no-cache \
	nginx \
	openssl

# Created dir for SSL certificate and set strict user permissions
RUN mkdir -p /etc/nginx/ssl/certs /etc/nginx/ssl/private && \
	chmod 755 /etc/nginx/ssl/certs && \
	chmod 700 /etc/nginx/ssl/private

# Generates self-signed SSL/TLS certificate (Transport Layer Security, modern replacement)
# -x509 = instant self-signed cert
# -sha256 = forces to use modern SHA-2 hash function
# -nodes = No Data Encryption Standard, i.e. no password
# -newkey rsa:4096 = generate secure 4096-bit RSA key for TLS handshake
# -keyout, -out = file locations
# -subj = pre-fills interactive fields
RUN openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:4096 \
	-keyout /etc/nginx/ssl/private/inception.key \
	-out /etc/nginx/ssl/certs/inception.crt \
	-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Student/CN=myli-pen.42.fr"

# Creates dir for NGINX PID file (needed by NGINX for legacy reasons)
RUN mkdir -p /var/run/nginx

# Copies NGINX configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Creates dir for web root
# Transfers ownership recursively to the restricted user group
RUN mkdir -p /var/www/html && \
	chown -R nobody:nobody /var/www/html

# Exposes HTTPS port
EXPOSE 443

# Starts NGINX in the foreground with PID 1
# -g = global directives
CMD ["nginx", "-g", "daemon off;"]
