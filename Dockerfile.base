FROM opensuse/leap:15

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

