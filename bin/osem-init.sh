#!/bin/bash
# Setup the app if it isn't already setup
bundle exec rake setup:bootstrap
# Start the app
foreman start -p 3000
