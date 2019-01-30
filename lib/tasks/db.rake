# frozen_string_literal: true

namespace :db do
  desc 'Bootstrap the database for the current RAILS_ENV (create, setup & seed if the database does not exist)'
  task bootstrap: :environment do
    if ActiveRecord::Base.connection.tables.empty?
      puts 'Bootstrapping the database...'
      Rake::Task['db:create'].invoke
      Rake::Task['db:setup'].invoke
      Rake::Task['db:seed'].invoke
    else
      puts 'Database exists, skipping bootstrap...'
    end
  end
end
