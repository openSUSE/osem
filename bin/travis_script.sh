#!/bin/bash
# This script runs the test suites for the CI build

# Be verbose and fail script on the first error
set -xe

# By default: all test runs
if [ -z $1 ]; then
  TEST_SUITE="all"
else
  TEST_SUITE="$1"
fi

case $TEST_SUITE in
  linters)
    bundle exec rubocop -Dc .rubocop.yml
    bundle exec haml-lint app/views
    ;;
  models)
    bundle exec rspec --format documentation spec/models
    ;;
  features)
    bundle exec rspec --format documentation spec/features
    ;;
  controllers)
    bundle exec rspec --format documentation spec/controllers
    ;;
  ability)
    bundle exec rspec --format documentation spec/ability
    ;;
  rest)
    bundle exec rspec --format documentation --exclude-pattern "spec/{models,features,controllers,ability}/**/*_spec.rb"
    ;;
esac
