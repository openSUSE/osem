# frozen_string_literal: true

require 'yaml'
task :dump_db do
  yaml = YAML.load_file('config/database.yml')
  conf = yaml['production']
  filename = "#{conf['database']}-#{Time.now.strftime('%Y-%m-%d-%H:%M:%S:%L')}.sql"
  if conf['adapter'] == 'mysql2'
    system "mysqldump -u #{conf['username']} --password=#{conf['password']} -h #{conf['host']} #{conf['database']} > ~/#{filename}"
  else
    puts 'Error: This rake task only works for MYSQL'
  end
end
