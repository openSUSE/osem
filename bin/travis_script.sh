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
  linters|all)
    bundle exec rubocop -Dc .rubocop.yml
    bundle exec haml-lint app/views
    ;;&
  models|all)
    bundle exec rspec --format documentation spec/models
    ;;&
  features|all)
    bundle exec rspec --format documentation spec/features
    ;;&
  controllers|all)
    bundle exec rspec --format documentation spec/controllers
    ;;&
  ability|all)
    bundle exec rspec --format documentation spec/ability
    ;;&
  rest|all)
    bundle exec rspec --format documentation --exclude-pattern "spec/{models,features,controllers,ability}/**/*_spec.rb"
    ;;
esac
