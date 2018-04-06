#!/bin/bash

# set env os release variables
. /etc/os-release

if [[ "$ID" == "opensuse" ]]; then

pushd /vagrant

echo -e "\ninstalling required software packages...\n"
zypper -q ar -f http://download.opensuse.org/repositories/devel:/languages:/ruby/openSUSE_Leap_42.2/devel:languages:ruby.repo
zypper -q --gpg-auto-import-keys --non-interactive ref
zypper -q -n install update-alternatives ruby2.4-devel make gcc gcc-c++ \
             libxml2-devel libxslt-devel nodejs screen mariadb \
             libmysqld-devel sqlite3-devel ImageMagick

echo -e "\ndisabling versioned gem binary names...\n"
echo 'install: --no-format-executable' >> /etc/gemrc

echo -e "\ninstalling bundler...\n"
gem.ruby2.4 install bundler

elif [[ "$ID" == "centos" || "$VERSION" == "7"  ]]; then
  _YELLOW='\033[1;33m' # yellow color
  _LRED='\033[1;31m' # Light red color
  _NO_COLOUR='\033[0m' # no color

  printf "${_YELLOW}CEntOS-7 Setup${_NO_COLOUR}\n"

  printf "${_YELLOW}installing ruby-2.4${_NO_COLOUR}\n"
  yum install -q -y https://github.com/feedforce/ruby-rpm/releases/download/2.4.2/ruby-2.4.2-1.el7.centos.x86_64.rpm
  if [[ ! "$?" -eq 0 ]]; then
    printf "${_LRED}Error trying to install ruby-2.4${_NO_COLOUR}\n"
  fi

  printf "${_YELLOW}installing ruby-2.4 gems dependencies${_NO_COLOUR}\n"
  gem install bundler
  if [[ ! "$?" -eq 0 ]]; then
    printf "${_LRED}Error trying to install ruby-2.4 bundler${_NO_COLOUR}\n"
  fi

  printf "${_YELLOW}installing nodejs repo${_NO_COLOUR}\n"
  curl -sL https://rpm.nodesource.com/setup_9.x | bash - > /dev/null

  printf "${_YELLOW}installing nodejs and devel tools${_NO_COLOUR}\n"
  yum install -q -y git make gcc gcc-c++ libxml2-devel libxslt-devel nodejs screen mariadb mariadb-devel sqlite-devel ImageMagick bzip2

  # for production: bundle install --without test development
  printf "${_YELLOW}Opening firewall port: 3000${_NO_COLOUR}\n"
  iptables -I INPUT -p tcp --dport 3000 -j ACCEPT

  printf "${_YELLOW}installing phantomjs${_NO_COLOUR}\n"
  curl -L --silent https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -o /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2
  tar jxvf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /tmp/  phantomjs-2.1.1-linux-x86_64/bin/phantomjs
  mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin

  pushd /vagrant
fi

echo -e "\ninstalling your bundle...\n"
su - vagrant -c "cd /vagrant/; bundle install --quiet"

# Configure the database if it isn't
if [ ! -f /vagrant/config/database.yml ] && [ -f /vagrant/config/database.yml.example ]; then
  echo -e "\nSetting up your database from config/database.yml...\n"
  cp config/database.yml.example config/database.yml
  if [ ! -f db/development.sqlite3 ] && [ ! -f db/test.sqlite3 ]; then
    su - vagrant -c "cd /vagrant/; bundle exec rake db:setup"
  else
    echo -e "\n\nWARNING: You have already have a development/test database."
    echo -e "WARNING: Please make sure this database works in this vagrant box!\n\n"
  fi
else
  echo -e "\n\nWARNING: You have already configured your database in config/database.yml."
  echo -e "WARNING: Please make sure this configuration works in this vagrant box!\n\n"
fi

echo -e "\nProvisioning of your OSEM rails app done!"
echo -e "To start your development OSEM run: vagrant exec bundle exec rails server -b 0.0.0.0\n"
