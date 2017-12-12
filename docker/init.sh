#! /bin/bash

set -e

# data directory is required for caching the secret key in a file
if [ "$DATA_DIR" == "" ]; then
    echo -n "Error: DATA_DIR environment variable not set!"
    echo "Are you sure you are running this script in a Docker container?"
    exit 1
fi

SECRET_KEY_FILE="$DATA_DIR/secret_key"

if [ ! -f "$SECRET_KEY_FILE" ]; then
    echo ">>> Creating a new secret key file..."
    install -m 0600 /dev/null "$SECRET_KEY_FILE"
    SECRET_KEY=$(bundle exec rake secret)
    echo "$key" > "$SECRET_KEY_FILE"
    chmod -w "$SECRET_KEY_FILE"
else
    SECRET_KEY=$(cat "$SECRET_KEY_FILE")
fi

export SECRET_KEY
export RAILS_ENV=production

install -m 0600 /dev/null .my.cnf
cat > .my.cnf <<ABC
[client]
user=$MYSQL_USER
password=$MYSQL_PASSWORD
ABC

echo ">>> Waiting for database to get ready to connect..."
dockerize -wait tcp://$DATABASE_HOST:$DATABASE_PORT -timeout 60s true

if [ $(echo "show tables;" | mysql --host $DATABASE_HOST --port $DATABASE_PORT $MYSQL_DATABASE | wc -l) -le 1 ]; then
    echo ">>> Initializing database..."
    bundle exec rake db:schema:load
    
    echo ">>> Seed database..."
    bundle exec rake db:seed
fi

echo ">>> Upgrading database..."
bundle exec rake db:migrate

rm .my.cnf

echo ">>> Precompiling assets..."
bundle exec rake assets:precompile

echo ">>> Starting application server..."
exec bundle exec rails server -e production -b 0.0.0.0 -p 9292
