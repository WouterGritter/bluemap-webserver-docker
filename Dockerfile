FROM trafex/php-nginx:latest

USER root

# Install PDO packages
RUN apk add --no-cache php84-pdo php84-pdo_mysql
RUN apk add --no-cache envsubst

# Allow to run php-fpm (and connect to it) as root
RUN sed -i 's|^command=php-fpm84 -F|command=php-fpm84 -F --allow-to-run-as-root|' /etc/supervisor/conf.d/supervisord.conf
RUN sed -i -e '/^[[:space:]]*listen *= *\/run\/php-fpm\.sock/ a listen.owner = root' -e '/^[[:space:]]*listen *= *\/run\/php-fpm\.sock/ a listen.group = root' -e '/^[[:space:]]*listen *= *\/run\/php-fpm\.sock/ a listen.mode  = 0666' "${PHP_INI_DIR}/php-fpm.d/www.conf"

# Remove site config and replace it with our own .template file (docker-entrypoint.sh will override with a non-template file)
RUN rm /etc/nginx/conf.d/default.conf
COPY ./default.conf.template /etc/nginx/conf.d/default.conf.template

WORKDIR /var/www/html

# Remove trafex/php-nginx default files
RUN rm *

# Download and unzip bluemap webroot
RUN wget https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v5.9/bluemap-5.9-webapp.zip
RUN unzip *.zip
RUN rm *.zip
RUN ls

# Modify the DB config in BlueMap's sql.php
RUN sed -ri "s|^[[:space:]]*\\\$hostname[[:space:]]*=[[:space:]]*[^;]+;|\\\$hostname = getenv('DB_HOSTNAME');|" sql.php
RUN sed -ri "s|^[[:space:]]*\\\$port[[:space:]]*=[[:space:]]*[^;]+;|\\\$port     = getenv('DB_PORT');|"         sql.php
RUN sed -ri "s|^[[:space:]]*\\\$username[[:space:]]*=[[:space:]]*[^;]+;|\\\$username = getenv('DB_USERNAME');|" sql.php
RUN sed -ri "s|^[[:space:]]*\\\$password[[:space:]]*=[[:space:]]*[^;]+;|\\\$password = getenv('DB_PASSWORD');|" sql.php
RUN sed -ri "s|^[[:space:]]*\\\$database[[:space:]]*=[[:space:]]*[^;]+;|\\\$database = getenv('DB_DATABASE');|" sql.php

# Set default environment variables
ENV DB_PORT=3306
ENV DB_USERNAME=root
ENV DB_DATABASE=bluemap

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
