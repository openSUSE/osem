# frozen_string_literal: true

namespace :db do
  desc 'Bootstrap the database for the current RAILS_ENV (create, setup & seed if the database does not exist)'
  task bootstrap: :environment do
    Rake::Task['db:create'].invoke
    if ActiveRecord::Base.connection.tables.empty?
      puts 'Bootstrapping the database...'
      Rake::Task['db:setup'].invoke
      Rake::Task['db:seed'].invoke
    else
      puts 'Database exists, skipping bootstrap...'
    end
  end

  desc "Import a given file into the database"
  task :import, [:path] => :environment do |_t, args|
    dump_path = args.path
    connection_config = ActiveRecord::Base.connection_config

    case connection_config[:adapter]
    when "postgresql"
      system("PGPASSWORD=#{connection_config[:password]} pg_restore " \
        "--verbose --clean --no-acl --no-owner " \
        "--username=#{connection_config[:username]} " \
        "-d #{connection_config[:database]} #{dump_path}")
    when "mysql", "mysql2"
      system("mysql -u #{connection_config[:username]} " \
        "-p#{connection_config[:password]} " \
        "#{connection_config[:database]} < #{dump_path}")
    else
      raise NotImplementedError, "An importer hasn't been implemented for: " \
        "#{connection_config[:adapter]}"
    end
  end
end
