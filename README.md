OSEM
====
The Open Source Event Manager. An event management tool tailored to Free and Open Source Software conferences.

Local Installation
==================

Ruby and Ruby on Rails:

* Install Ruby v. 1.9.3, guide at https://gist.github.com/AstonJ/2896818 for CentOS.
  Debian has Ruby v. 1.9.3 packaged into the Testing suite already.
* Install Apache + mod_passenger, an handy guide is available at:
  http://nathanhoad.net/how-to-ruby-on-rails-ubuntu-apache-with-passenger

OSEM:

Dependencies:

* git clone https://github.com/openSUSE/osem.git on the directory you want Apache
  to serve the content from. (in our example, '/srv/http/osem.example.org')
* Run bundle install for getting all the needed gems.
* Install ImageMagick with either 'yum install ImageMagick' or 'apt-get install imagemagick'

Configuration files:

* cp config/config.yml.example config/config.yml
* cp config/database.yml.example config/database.yml

Directories and permissions:

* cd into the root directory for your OSEM app
* mkdir storage cache system
* chown all the files and directories to the user that runs
  apache. (www-data on Ubuntu / Debian, apache on CentOS/Fedora/RHEL)

Database: 

* bundle exec rake db:setup
* bundle exec rake db:migrate
* bundle exec rake db:seed

Apache:

* Create a new vhost that should look like this:

"""
<VirtualHost *:80>
   ServerName osem.example.org
   DocumentRoot /srv/http/osem.example.org/public
   RailsEnv development

   <Directory /srv/http/osem.example.org/public>
     # This relaxes Apache security settings.
     AllowOverride all
     # MultiViews must be turned off.
     Options -MultiViews
   </Directory>
</VirtualHost>
"""

* Connect to osem.example.org and register your first user. Make
  also sure that Postfix is installed and configured on the system
  for the confirmation mail to pass through.

Caveats
=======

To make the first registered user an admin:

* rails console
* Check for available users with 'User.all'
* If your user's ID is [1] then do: "hero = User.find('1')"
* Give yourself admin status with "hero.role_ids=[3]"

If you have problems with rails console, try this in the Gemfile: 

* gem uninstall rb-readline
* gem 'rb-readline', '~>0.4.2'

If you have problems with jquery-ui, try this in the Gemfile:

* gem "jquery-rails", "~> 2.3.0"

Or make the needed change as explained at http://stackoverflow.com/questions/17830313/couldnt-find-file-jquery-ui.
