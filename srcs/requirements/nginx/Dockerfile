FROM alpine:3.23

# Installs NGINX and OpenSSL (Secure Sockets Layer, encrypts internet traffic)
RUN apk update && apk add --no-cache \
	nginx \
	openssl

# Created dir for SSL certificate
RUN mkdir -p /etc/nginx/ssl

# Generates self-signed SSL/TLS certificate (Transport Layer Security, modern replacement)
# -x509 = instant self-signed cert
# -nodes = No Data Encryption Standard, i.e. no password
# -newkey rsa:2048 = generate secure 2048-bit RSA key for TLS handshake
# -keyout, -out = file locations
# -subj = pre-fills interactive fields
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
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
