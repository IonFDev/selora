FROM php:8.4-apache

# ── Sistema ──────────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
 && docker-php-ext-install pdo_mysql mbstring zip exif pcntl opcache \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ── OPcache (el mayor boost de rendimiento para PHP) ─────────────────────────
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.revalidate_freq=0'; \
    echo 'opcache.validate_timestamps=1'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache.ini

# ── PHP ajustes generales ─────────────────────────────────────────────────────
RUN { \
    echo 'memory_limit=256M'; \
    echo 'upload_max_filesize=64M'; \
    echo 'post_max_size=64M'; \
    echo 'max_execution_time=60'; \
} > /usr/local/etc/php/conf.d/custom.ini

# ── Apache ────────────────────────────────────────────────────────────────────
RUN a2enmod rewrite headers deflate expires

ENV APACHE_DOCUMENT_ROOT=/var/www/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
 && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Compresión y caché de assets estáticos
RUN { \
    echo '<IfModule mod_deflate.c>'; \
    echo '  AddOutputFilterByType DEFLATE text/html text/css application/javascript application/json'; \
    echo '</IfModule>'; \
    echo '<IfModule mod_expires.c>'; \
    echo '  ExpiresActive On'; \
    echo '  ExpiresByType text/css "access plus 1 year"'; \
    echo '  ExpiresByType application/javascript "access plus 1 year"'; \
    echo '  ExpiresByType image/png "access plus 1 year"'; \
    echo '  ExpiresByType image/jpeg "access plus 1 year"'; \
    echo '  ExpiresByType image/svg+xml "access plus 1 year"'; \
    echo '</IfModule>'; \
} > /etc/apache2/conf-available/performance.conf \
 && a2enconf performance

# ── Composer ──────────────────────────────────────────────────────────────────
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ── App ───────────────────────────────────────────────────────────────────────
WORKDIR /var/www

# Primero solo las dependencias para aprovechar caché de capas de Docker
COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-scripts --no-interaction

COPY . /var/www

RUN composer dump-autoload --optimize \
 && chown -R www-data:www-data storage bootstrap/cache || true

EXPOSE 80