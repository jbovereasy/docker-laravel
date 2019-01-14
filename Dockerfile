FROM ubuntu:xenial-20181218

# Update Ubuntu Machine & set UTC
RUN apt-get update && apt-get install -y locales \
  && locale-gen en_US.UTF-8 \

  # Install software-properties-common & python-software-properties to install apt-add-repository
  && apt-get install -y software-properties-common python-software-properties \

  # Add php7.2 & phpunut repository list
  && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
  && add-apt-repository ppa:jonathonf/backports \
  && apt-get update \

  # Install Dev Stack
  && apt-get install -y \
  apache2 \
  curl \
  git \
  libcurl4-openssl-dev \
  libssl-dev \
  pkg-config \
  php7.2 \
  php7.2-dev \  
  php7.2-ldap \
  php7.2-mbstring \
  php7.2-memcached \
  php-pear \
  php-pecl-http \ 
  php-pecl-http-dev \
  php7.2-xml \
  php7.2-zip \
  unzip \
  vim \
  wget \

  && a2enmod rewrite \
  && a2enmod headers \
  && a2enmod php7.2 \
  && service apache2 restart \

  # Install composer
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && pecl install mongodb \

  # Install NVM
  && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \

  # Source .bashrc
  && . ~/.bashrc \

  # Install npm
  && nvm install --lts \
  && npm install -g yarn \

  # Clean image
  && npm cache clean --force && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* \

  # Add 1000 and Staff to www-data group for correct permissions
  && usermod -u 1000 www-data && usermod -G staff www-data \

  # Chown directories owned by www-data
  && chown -hR www-data:www-data /var/www/ \

  # Prevents error message when docker cannot determine domain name
  && echo ServerName localhost >> /etc/apache2/apache2.conf

#Set environment variables
ENV APACHE_RUN_USER=www-data \
  APACHE_RUN_GROUP=www-data \
  APACHE_LOG_DIR=/var/log/apache2 \
  APACHE_PID_FILE=/var/run/apache2.pid \
  APACHE_RUN_DIR=/var/run/apache2 \
  APACHE_LOCK_DIR=/var/lock/apache2

#Create directories
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

#Mount Volumes
VOLUME ["/var/www/"]

# Set /var/www/ as working directory
WORKDIR /var/www/

# Copy Config files
COPY config/apache.conf /etc/apache2/sites-available/000-default.conf
COPY config/php.ini /etc/php/7.2/apache2/php.ini

# Expose port 80
EXPOSE 80

CMD ["apache2", "-D", "FOREGROUND"]
