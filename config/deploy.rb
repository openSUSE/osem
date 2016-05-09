require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, 'proxy-opensuse.suse.de'
set :port, 2214
set :user, 'osem'
set :deploy_to, '/srv/www/vhosts/opensuse.org/events'
set :repository, 'https://github.com/openSUSE/osem.git'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, %w{ config/database.yml log public/system config/secrets.yml config/piwik.yml tmp .env.production}

task setup: :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]

  queue! %[touch "#{deploy_to}/shared/system"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/system"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  to :prepare do
    queue "cd #{deploy_to}/current && RAILS_ENV=production bin/delayed_job stop"
  end

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'dump_db'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    #invoke :notify_errbit

    to :launch do
      queue "sudo /etc/init.d/apache2 restart"
      queue "cd #{deploy_to}/current && RAILS_ENV=production bin/delayed_job start"
    end

    invoke :'deploy:cleanup'
  end
end

desc 'Notifies the exception handler of the deploy.'
task :notify_errbit do
  revision = `git rev-parse HEAD`.strip
  user = ENV['USER']
  queue "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake hoptoad:deploy TO=#{rails_env} REVISION=#{revision} REPO=#{repository} USER=#{user}"
end

desc 'Back ups the database'
task :dump_db do
  queue "bundle exec rake dump_db"
end
