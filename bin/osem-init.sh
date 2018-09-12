#!/bin/bash
# Configure our bundle
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1
# Install our bundle if it's outdated
bundle check || bundle install --jobs=3 --retry=3
# Setup the app if it isn't already setup
bundle exec rake setup:bootstrap
# Start the app
foreman start
