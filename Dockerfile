FROM registry.opensuse.org/opensuse/infrastructure/dale/containers/osem/base:latest
ARG CONTAINER_USERID

# Configure our user
RUN usermod -u $CONTAINER_USERID osem

# We copy the Gemfiles into this intermediate build stage so it's checksum
# changes and all the subsequent stages (a.k.a. the bundle install call below)
# have to be rebuild. Otherwise, after the first build of this image,
# docker would use it's cache for this and the following stages.
COPY Gemfile /osem/
COPY Gemfile.lock /osem/
RUN chown -R osem /osem

# Install bundler & foreman
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" /osem/Gemfile.lock | tail -n 1)"; \
    gem install foreman

# Continue as user
USER osem
WORKDIR /osem/

# Install our bundle
RUN bundle install --jobs=3 --retry=3

CMD ["foreman", "start"]
