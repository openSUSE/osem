#!/usr/bin/ruby
# frozen_string_literal: true

#
# More info at https://github.com/guard/guard#readme

guard_opts = {
  all_on_start:   true,
  all_after_pass: true,
  cmd:            'spring rspec'
}

def model_specs       ; 'spec/models'       end

def model_spec(model)
  "spec/models/#{model}_spec.rb"
end

def all_testunit_tests
  [
    model_tests,
    controller_tests,
    helper_tests,
    integration_tests,
  ]
end

def all_specs
  [
    model_specs,
  ]
end

def startup_guards
  watch(%r{^Gemfile$})                      { yield }
  watch(%r{^Gemfile.lock$})                 { yield }
  watch(%r{^config/routes.rb$})             { yield }
  watch(%r{^config/application\.rb$})       { yield }
  watch(%r{^config/environment\.rb$})       { yield }
  watch(%r{^config/environments/.+\.rb$})   { yield }
  watch(%r{^config/initializers/.+\.rb$})   { yield }
  watch(%r{^db/schema\.rb$})                { yield }
  watch(%r{^spec/spec_helper\.rb$})         { yield }
end

def rspec_guards
  watch(%r{^spec/factories/.+\.rb$})        { all_specs }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                 { |m| "spec/#{m[1]}_spec.rb" }
end

group :rspec do
  guard 'rspec', guard_opts do
    #startup_guards { all_specs }
    rspec_guards
    #all_specs
  end
end

# group :bundler do
#   guard 'bundler' do
#     watch('Gemfile')
#     # Uncomment next line if Gemfile contain `gemspec' command
#     # watch(/^.+\.gemspec/)
#   end
# end
