FROM ruby:2.3

MAINTAINER TheAssassin <theassassin@users.noreply.github.com>

# required for compiling assets
RUN apt-get update && \
    apt-get install -y nodejs nodejs-legacy mariadb-client imagemagick

# used to run the container without root permissions
RUN adduser --home /osem/ --system --group --disabled-login --disabled-password osem

# required to detect when the database is up and running in init.sh
RUN cd /usr/bin && \
    wget https://github.com/jwilder/dockerize/releases/download/v0.3.0/dockerize-linux-amd64-v0.3.0.tar.gz -O dockerize.tar.gz && \
    echo "36e8319cdf9d2b07340f456ec61cfa0f495ec6c130b02ad9c116fd55a5c43fa1  dockerize.tar.gz" | sha256sum -c && \
    tar -xf dockerize.tar.gz && \
    rm dockerize.tar.gz

# explicitly add Gemfile and install dependencies using bundler to make use of
# Docker's caching
WORKDIR /osem/
COPY Gemfile /osem/
COPY Gemfile.lock /osem/
RUN bundle install --without test development

# add OSEM files and prepare them for use inside a Docker container
COPY . /osem/
RUN chown osem.osem /osem/ -R && \
    mv /osem/config/database.yml.docker /osem/config/database.yml

# data directory is used to cache the secret key in a file
ENV DATA_DIR /data
RUN install -d -m 0700 -o osem $DATA_DIR
VOLUME ["$DATA_DIR"]

USER osem
EXPOSE 9292

COPY docker/init.sh /init.sh

# a user could override this if they wanted to serve the static files directly
# from a webserver
ENV RAILS_SERVE_STATIC_FILES 1

CMD ["bash", "/init.sh"]
