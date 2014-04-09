[![Code Climate](https://codeclimate.com/github/openSUSE/osem.png)](https://codeclimate.com/github/openSUSE/osem)
[![Coverage Status](https://coveralls.io/repos/openSUSE/osem/badge.png)](https://coveralls.io/r/openSUSE/osem)
#OSEM
The Open Source Event Manager. An event management tool tailored to Free and Open Source Software conferences.

## Install OSEM
You can run rails apps in different modes (development, production). For more information
about rails and what it can do, see the [rails guides.](http://guides.rubyonrails.org/getting_started.html)

### Run OSEM in development
1. Clone the git repository to the directory you want Apache to serve the content from.
```
git clone https://github.com/openSUSE/osem.git
```
2. Install all the ruby gems.
```
bundle install
```
3. Install ImageMagick from your distribution repository
4. Copy the sample configuration files and adapt them
```
cp config/config.yml.example config/config.yml
cp config/database.yml.example config/database.yml
```
6. Setup the database
```
bundle exec rake db:setup
```
7. Run OSEM
```
rails server
```
8. Visit the APP at 
```
http://localhost:3000
```
9. Sign up, the first user will be automatically assigned the admin role.

### Run OSEM in production
We recommend to run OSEM in production with [mod_passenger](https://www.phusionpassenger.com/download/#open_source)
and the [apache web-server](https://www.apache.org/). There are tons of guides on how to deploy rails apps on various
base operating systems. Check Google ;-)

## Documentation
OSEM is extensively (some would say maniacally ;-) documented. You can generate a nice HTML documentation with ''rdoc''
```
bundle exec rdoc --op doc/app --all -f fivefish app 
xdg-open doc/app/index.html 
```

## Testing
We are using [rspec](http://rspec.info/)+[capybara](http://jnicklas.github.io/capybara/)+[factory girl](https://github.com/thoughtbot/factory_girl) as test suite. You *should* run it, whenever you change something, with
```
bundle exec rake rspec
```
