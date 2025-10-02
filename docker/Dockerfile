FROM pkpofficial/ojs:3_4_0-5
WORKDIR /var/www/html

# Paketlar
RUN apk update && apk add --no-cache curl zip unzip

# Kerakli modullar (idempotent)
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule headers_module/LoadModule headers_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule setenvif_module/LoadModule setenvif_module/' /etc/apache2/httpd.conf

# (Agar sizda katalog konfiguratsiyalari ham bo'lsa)
COPY config/ /var/www/html/config/

# ⚠️ MUHIM: OJS asl konfiguratsiya fayli ildizda bo'ladi
COPY config.inc.php /var/www/html/config.inc.php

# HTTPS forwarded belgisi (Traefik TLS terminatsiya qiladi)
RUN printf "\n# Trust reverse proxy HTTPS\nSetEnvIf X-Forwarded-Proto \"https\" HTTPS=on\nSetEnvIf X-Forwarded-Port \"443\" SERVER_PORT=443\n" >> /var/www/html/.htaccess

# PHP auto-prepend
COPY https_forwarded.php /var/www/html/https_forwarded.php
COPY .user.ini /var/www/html/.user.ini

# Apache konfini conf.d orqali ulash (append emas!)
COPY apache-https-no-tls.conf /etc/apache2/conf.d/zzz-proxy-logs.conf

# Ruxsatlar: html va loglar yoziladigan bo'lsin
RUN chown -R apache:apache /var/www/html && \
    find /var/www/html -type d -exec chmod 775 {} \; && \
    find /var/www/html -type f -exec chmod 664 {} \; && \
    mkdir -p /var/www/logs && \
    chown -R apache:apache /var/www/logs && chmod -R 775 /var/www/logs

# Apache foreground
CMD ["sh","-c","httpd -D FOREGROUND"]
