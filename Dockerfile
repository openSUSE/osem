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

# Continue as user
USER osem
WORKDIR /osem/

# Install our bundle
RUN bundle config set --local path 'vendor/bundle'; \
    bundle install --jobs=4 --retry=3

# Install our process manager
RUN sudo gem install foreman

CMD ["foreman", "start"]
