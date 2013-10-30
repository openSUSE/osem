#OSEM
The Open Source Event Manager. An event management tool tailored to Free and Open Source Software conferences.

##Local Installation

### Install Ruby and Ruby on Rails:

* Install Ruby v. 1.9.3, guide at https://gist.github.com/AstonJ/2896818 for CentOS.
  Debian has Ruby v. 1.9.3 packaged into the Testing suite already.
* Install Apache + mod_passenger, an handy guide is available at:
  http://nathanhoad.net/how-to-ruby-on-rails-ubuntu-apache-with-passenger

### Install OSEM
1. Clone the git repository to the directory you want Apache to serve the content from.
```
git clone https://github.com/openSUSE/osem.git
```
2. Install all the ruby gems.
```
bundle install
```
3. Install ImageMagick

* Fedora/CentOS:

```
yum install ImageMagick
```

* Ubuntu/Debian:

```
apt-get install imagemagick
```

4. Copy the sample configuration files
```
cp config/config.yml.example config/config.yml
cp config/database.yml.example config/database.yml
```

5. Setup directories and permissions:
```
mkdir storage cache system
```
* Fedora/CentOS
```
chown apache storage cache system
```
* Debian/Ubuntu
```
chown www-data storage cache system
```

6. Setup the database
```
bundle exec rake db:setup
bundle exec rake db:migrate
bundle exec rake db:seed
```

7. Create a new Apache vhost that should look like this:
```
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
```

7. Connect to osem.example.org and register your first user. Make also sure that Postfix is installed and configured on the system for the confirmation mail to pass through.

8. To make the first registered user an admin:
```
rails console
User.all
me = User.find('1')
me.role_ids=[3]
```

Caveats
=======

If you have problems with rails console, try this in the Gemfile: 

* gem uninstall rb-readline
* gem 'rb-readline', '~>0.4.2'

If you have problems with jquery-ui, try this in the Gemfile:

* gem "jquery-rails", "~> 2.3.0"

Or make the needed change as explained at http://stackoverflow.com/questions/17830313/couldnt-find-file-jquery-ui.
