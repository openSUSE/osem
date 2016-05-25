namespace :db do
  desc 'setup DATABASE_URL from CLEARDB_DATABASE_URL in config/database.yml'
  task 'cleardb_env' do
    unless ENV['CLEARDB_DATABASE_URL'].nil?
      FileUtils.copy_file('config/database.yml.heroku', 'config/database.yml')
    end
  end
end
