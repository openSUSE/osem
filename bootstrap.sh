#!/bin/bash

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

echo -e "\ninstalling your bundle...\n"
su - vagrant -c "cd /vagrant/; bundle install --quiet"

echo -e "\nConfiguring the app...\n"
su - vagrant -c "cd /vagrant/; bundle exec rake db:bootstrap"

echo -e "\nProvisioning of your OSEM rails app done!"
echo -e "To start your development OSEM run: vagrant exec bundle exec rails server -b 0.0.0.0\n"
