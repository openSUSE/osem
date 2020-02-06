#!/bin/bash
bundle install
# Setup the app if it isn't already setup
bundle exec rake db:bootstrap
# Start the app
foreman start -p 3000
