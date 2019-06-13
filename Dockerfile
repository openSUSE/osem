FROM opensuse/leap:15 as base

# Import google packaging key for chrome
COPY google-packaging.key /tmp
RUN rpm --import /tmp/google-packaging.key

# Enable/Disable the repositories we need/don't need
RUN zypper rr openSUSE-Leap-15.0-Non-Oss openSUSE-Leap-15.0-Update-Non-Oss; \
    zypper ar -f https://download.opensuse.org/repositories/devel:/tools/openSUSE_Leap_15.0/devel:tools.repo; \
    zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome; \
    zypper --gpg-auto-import-keys refresh

# Install our requirements
RUN zypper -n install --no-recommends \
    # for compiling assets/gems
    nodejs8 gcc-c++ git-core make \
    # for ...
    ImageMagick \
    # for bundler
    sudo \
    # as databases
    libmariadb-devel postgresql-devel sqlite3-devel \
    # for nokogiri
    libxml2-devel libxslt-devel \
    # for the interactive shell
    ack curl wget w3m vim \
    # for running our tests
    phantomjs which \
    # as ruby
    ruby2.5-devel \
    # as browser for feature tests
    google-chrome-stable

# Setup sudo
RUN echo 'osem ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Disable versioned gem binary names
RUN echo 'install: --no-format-executable' >> /etc/gemrc

# Install bundler & foreman
RUN gem install bundler:1.17.3 foreman

# Create our user
RUN useradd -m --user-group osem

CMD ["/bin/bash", "-l"]

FROM base

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

# Install our bundle
RUN export NOKOGIRI_USE_SYSTEM_LIBRARIES=1; bundle install --jobs=3 --retry=3

CMD ["foreman", "start"]
