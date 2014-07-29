[![Stories in Ready](https://badge.waffle.io/opensuse/osem.png?label=ready&title=Ready)](https://waffle.io/opensuse/osem)
[![Build Status](https://travis-ci.org/openSUSE/osem.svg?branch=master)](https://travis-ci.org/openSUSE/osem)
[![Code Climate](https://codeclimate.com/github/openSUSE/osem.png)](https://codeclimate.com/github/openSUSE/osem)
[![Coverage Status](https://coveralls.io/repos/openSUSE/osem/badge.png)](https://coveralls.io/r/openSUSE/osem)
[![Security Status](https://hakiri.io/github/openSUSE/osem/master.svg)](https://hakiri.io/github/openSUSE/osem/master)
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
4. Generate secret key for devise and the rails app with
```
rake secret
```
Look at config/config.yml.example.

5. Copy the sample configuration files and adapt them
```
cp config/config.yml.example config/config.yml
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
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

10. Use openID
In order to use the OpenID feature you need to register your application with the providers
(Google and Facebook) and enter their API keys in config/secrets.yml file, changing the existing sample values.

You can register as a devoloper with Google from https://code.google.com/apis/console#:access
You can register as a devoloper with Facebook from https://developers.facebook.com/,
by selecting from the top menu the option 'Apps' -> 'Create a New App'

Unless you add the key and secret for each provider, you will not be able to see the image that
redirects to the login page of the provider.

If you add a provider that does not require developers to register their application, you still need
to create two (2) variables, in config/secrets.yml
with the format of providername_key and providername_secret and add some sample text as their values.
Example:
myprovider_key = 'sample data'
myprovider_secret = 'sample data'

That is required so that the check in app/views/devise/shared/_openid.html.haml will pass and
the image-link to login using the provider will be shown.

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
We are using [rspec](http://rspec.info/)+[capybara](http://jnicklas.github.io/capybara/)+[factory girl](https://github.com/thoughtbot/factory_girl) to build test suite. You *should* run it continuously when you are developing, via:
```
bundle exec guard
```
This uses [spring](https://github.com/rails/spring) to provide a
[fast feedback loop for the red/green cycle](http://bitzesty.com/blog/2013/05/enable-tdd-with-faster-ruby-on-rails-stack-reloading/).

Generally, no PR with decreased test coverage should be accepted. Please look closely on comments which been provided
by Coveralls in your PR.


## Style
We are using [rubocop](https://github.com/bbatsov/rubocop) as a style checker. It is running each time
Travis run its testing routine. If you want to run it locally just `bundle exec rubocop`. 
You can read through current enabled rules in `.rubocop.yml` file. Explanations of the defined [rules](http://rubydoc.info/github/bbatsov/rubocop/master/frames) can be found in modules [Cop::Lint](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Lint) and [Cop::Style](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Style).
Additionally you can read through [community ruby style-guide](https://github.com/bbatsov/ruby-style-guide) to better understand core principles.

# Communication
GitHub issues are the primary way for communicating about specific proposed
changes to this project. If you have other questions feel free to subscribe to
the [opensuse-web@opensuse.org](http://lists.opensuse.org/opensuse-web/)
mailinglist, all OSEM contributors are on that list! Additionally you can use #osem channel
on freenode IRC.
