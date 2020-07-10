FROM osem/base
ARG CONTAINER_USERID
ARG OSEM_RUBY_VERSION

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

# Install our bundle
RUN export NOKOGIRI_USE_SYSTEM_LIBRARIES=1; bundle install --jobs=3 --retry=3

CMD ["foreman", "start"]
