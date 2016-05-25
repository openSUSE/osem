namespace :db do
  desc 'setup DATABASE_URL from CLEARDB_DATABASE_URL in .env'
  task cleardb_env: :environment do
    unless ENV['CLEARDB_DATABASE_URL'].nil?
      cleardb_url = ENV['CLEARDB_DATABASE_URL'].gsub(/^mysql:\/\//, 'mysql2://')
      dot_env = File.open(Rails.root.join(".env"), 'w')
      dot_env.puts "DATABASE_URL=\"#{cleardb_url}\""
      dot_env.close
    end
  end
end
