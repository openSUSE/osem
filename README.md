OSEM
====
The Open Source Event Manager. An event management tool tailored to Free and Open Source Software conferences.

Local Installation
==================
* install [ImageMagick](http://www.imagemagick.org/) to your system
* cp config/config.yml.example config/config.yml
* cp config/database.yml.example config/database.yml
* bundle install
* bundle exec rake db:setup
* bundle exec rake db:seed
* GOTO http://0.0.0.0:3000 and register a user

Prodcution Deployment
=====================
Coming soon, but basically like any other rails app...

Configuration
=============
To make the first registered user an admin
* rails console
* hero = User.find('1')
* hero.role_ids=[3]


Caveats
=======
If you have problems with rails console, try this in the Gemfile

* gem 'rb-readline', '~>0.4.2'

If you have problems with jquery-ui try this in the Gemfile

* gem "jquery-rails", "~> 2.3.0"
