# frozen_string_literal: true

# Source: https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher

RSpec::Matchers.define :match_response_schema do |schema|
  match do |json|
    schema_directory = "#{Dir.pwd}/spec/support/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, json, strict: true)
  end
end
