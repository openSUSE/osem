# frozen_string_literal: true

require 'fileutils'

namespace :setup do
  task :configure do
    puts 'Setting up the database configuration...'
    copy_example_file('config/database.yml')
    copy_example_file(".env.#{Rails.env}", 'dotenv.example')
  end

  desc 'Bootstrap the application'
  task bootstrap: [:configure, :environment] do
    puts 'Creating the database...'
    begin
      # Only do this if the database does not exist...
      Rake::Task['db:version'].invoke
      # rubocop:disable Style/RescueStandardError
    rescue
      # rubocop:enable Style/RescueStandardError
      Rake::Task['db:create'].invoke
      Rake::Task['db:setup'].invoke
      Rake::Task['db:seed'].invoke
    end

    if Rails.env.test? || Rails.env.production?
      puts 'Prepare assets'
      Rake::Task['assets:clobber'].invoke
      Rake::Task['assets:precompile'].invoke
    end

    if Rails.env.development?
      puts 'Removing assets'
      Rake::Task['assets:clobber'].invoke
    end
  end
end

def copy_example_file(example_file, source_file = nil)
  if File.exist?(example_file) && !ENV['FORCE_EXAMPLE_FILES']
    example_file = File.join(File.expand_path(File.dirname(__FILE__) + '/../..'), example_file)
    puts "WARNING: You already have the config file #{example_file}, skipping..."
  else
    source_file ||= "#{example_file}.example"
    puts "Creating #{example_file} from #{source_file}"
    FileUtils.copy_file(source_file, example_file)
  end
end
