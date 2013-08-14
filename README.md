OSEM
====
The Open Source Event Manager. An event management tool tailored to Free and Open Source Software conferences.

Installation
============
* install [ImageMagick](http://www.imagemagick.org/)
* cp config/config.yml.example config/config.yml
* cp config/database.yml.example config/database.yml
* bundle install
* bundle exec rake db:setup
* bundle exec rake db:seed
* GOTO http://0.0.0.0:3000 and register a user

Configuration
=============
To make the first registered user an admin
* rails console
  -> hero = User.find('1')
  -> hero.role_ids=[3]
