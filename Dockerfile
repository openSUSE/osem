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

# Add our files
USER osem
WORKDIR /osem/

# Install bundler & foreman
RUN sudo gem install bundler:1.17.3 foreman
# Install our bundle
RUN export NOKOGIRI_USE_SYSTEM_LIBRARIES=1; bundle install --jobs=3 --retry=3

CMD ["foreman", "start"]
