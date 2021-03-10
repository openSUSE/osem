# frozen_string_literal: true

unless Rails.env.production?
  namespace :spec do
    desc 'rspec ability'
    task :ability do
      sh 'bundle exec rspec --format documentation spec/ability'
    end
    desc 'rspec models'
    task :models do
      sh 'bundle exec rspec --format documentation spec/models'
    end
    desc 'rspec controllers'
    task :controllers do
      sh 'bundle exec rspec --format documentation spec/controllers'
    end
    desc 'rspec features'
    task :features do
      sh 'bundle exec rspec --format documentation spec/features'
    end
    desc 'rspec the leftovers'
    task :leftovers do
      sh 'bundle exec rspec --format documentation --exclude-pattern "spec/{models,features,controllers,ability}/**/*_spec.rb"'
    end
  end
end
