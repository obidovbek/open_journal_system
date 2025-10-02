FROM pkpofficial/ojs:3_4_0-5

WORKDIR /var/www/html

# Qo'shimcha paketlar
RUN apk update && apk add --no-cache curl zip unzip

# Apache modullari (agar baza image allaqachon yoqqan bo'lsa, bu qadam idempotent)
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule headers_module/LoadModule headers_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule setenvif_module/LoadModule setenvif_module/' /etc/apache2/httpd.conf

# OJS konfiguratsiyalari
COPY config/ /var/www/html/config/

# ⚠️ MUHIM: kataloglar yoziladigan bo'lsin (sed TMP fayl yaratadi)
# Kataloglar 775, fayllar 664, egasi apache:apache
RUN chown -R apache:apache /var/www/html && \
    find /var/www/html -type d -exec chmod 775 {} \; && \
    find /var/www/html -type f -exec chmod 664 {} \;

# Reverse proxy ortidan HTTPS ni ishonchli belgilash
RUN printf "\n# Trust reverse proxy HTTPS\nSetEnvIf X-Forwarded-Proto \"https\" HTTPS=on\nSetEnvIf X-Forwarded-Port \"443\" SERVER_PORT=443\n" >> /var/www/html/.htaccess

# PHP auto-prepend
COPY https_forwarded.php /var/www/html/https_forwarded.php
COPY .user.ini /var/www/html/.user.ini

# Apache konfini kengaytirish (TLS talab qilmaydigan qismni qo'shing)
# Agar sizning apache-https.conf ichida SSLCertificateFile/Key bor bo'lsa, ularni olib tashlang yoki comment qiling
COPY apache-https-no-tls.conf /etc/apache2/conf.d/zzz-proxy-logs.conf
# Log katalogi (Apache bu yerga yoza olishi shart)
RUN mkdir -p /var/www/logs && \
    chown -R apache:apache /var/www/logs && \
    chmod -R 775 /var/www/logs

# (ixtiyoriy) cron ishlamasa ham container yiqilmasin
# Agar entrypoint crond ni chaqirsa, daryomizga ta'sir qilmaydi:
ENV OJS_DISABLE_CRON=true

# Port
EXPOSE 80

# Apache'ni foregroundda ushlab turish (baza image konflikt qilmasa)
CMD ["sh", "-c", "httpd -D FOREGROUND"]
