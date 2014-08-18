[![Stories in Ready](https://badge.waffle.io/opensuse/osem.png?label=ready&title=Ready)](https://waffle.io/opensuse/osem)
[![Build Status](https://travis-ci.org/openSUSE/osem.svg?branch=master)](https://travis-ci.org/openSUSE/osem)
[![Code Climate](https://codeclimate.com/github/openSUSE/osem.png)](https://codeclimate.com/github/openSUSE/osem)
[![Coverage Status](https://coveralls.io/repos/openSUSE/osem/badge.png)](https://coveralls.io/r/openSUSE/osem)
[![Security Status](https://hakiri.io/github/openSUSE/osem/master.svg)](https://hakiri.io/github/openSUSE/osem/master)
#OSEM
The Open Source Event Manager. An event management tool tailored to Free and Open Source Software conferences.

## Installation and production usage

please refer to [INSTALL](INSTALL.md) documentation file

## Development discipline

Our [team](https://github.com/openSUSE/osem/graphs/contributors) is following agile methodologies to deliver best and
as fast as we can. There are some things which we embrace

# Sprints

* once in a while (2 weeks, currently) we catch up on freenode#osem to review results of previous sprint and plan next one.
* date of the meeting is discussed and chosen beforehand with preference to friday (Milestone in Github terms)
* on meeting we discuss what is achieved and what is not
* we do planning of next sprint tasks. It is a commitment. We will do our best to deliver what we agreed on
* we use [waffle.io](https://waffle.io/opensuse/osem) to track current GH issues/pull requests
* what is planned for current sprint is observable in `ready` column (each issue marked with label with same name)
* what is delivered is in done columnt
* what is in progress lives in respecitive column
* each person assigned in ready column to an issue is acting on his task

# Issues

please refer to our [CONTRIBUTING guide](CONTRIBUTING.md)

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
