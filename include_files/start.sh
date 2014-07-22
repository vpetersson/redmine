#!/bin/bash
set -e

prepare_fs() {
  echo "Creating necessary folders and setting permission..."
  mkdir -p /usr/local/redmine/{log,files,tmp,tmp/pdf,public/plugin_assets}
  chown -R www-data:www-data /usr/local/redmine*
  chmod -R 0755 /usr/local/redmine/{files,tmp,tmp/pdf,public/plugin_assets}
}

# Only run the migration if the environment
# variable 'RUN_MIGRATION' is set.
run_migration() {
  echo "Running Redmine migration scripts..."
  cd /usr/local/redmine
  RAILS_ENV=production rake db:migrate
}

generate_secret() {
  echo "Generating secret..."
  cd /usr/local/redmine
  RAILS_ENV=production rake generate_secret_token
}

# Install the bundle. This is useful if you install
# a new plugin that adds new dependencies.
install_bundle() {
  echo "Installing bundle..."
  cd /usr/local/redmine
  RAILS_ENV=production bundle install --without development test
}

launch_apache() {
  echo "Launching Apache..."
  apache2ctl \
    -f /etc/apache2/redmine_apache.conf \
    -D FOREGROUND
}

# If 'ENABLE_GIT_USER' is set, create a `git` user
# and add www-data to the user. This is useful if you
# need to access a git repository on the host server.
enable_git_user() {
  echo "Adding 'git' user and group..."
  groupadd -g 3002 git
  useradd -u 3002 -g git git
  usermod -a -G git www-data
}

# If 'ENABLE_LINKED_MYSQL' is set, this function
# will generate your database.yml file based on a
# set of environment variables. This is useful when
# you're using a linked MySQL container.
generate_database_yml() {
  echo -e "production:\n \
  adapter: mysql2\n \
  database: $REDMINE_DB\n \
  host: $MYSQL_PORT_3306_TCP_ADDR\n \
  port: $MYSQL_PORT_3306_TCP_PORT\n \
  username: $REDMINE_DB_USER\n \
  password: \"$REDMINE_DB_PASS\"\n \
  encoding: utf8" > \
  /usr/local/redmine/config/database.yml
}

# Make sure the permissions are properly set.
prepare_fs

if [ -n "$ENABLE_LINKED_MYSQL" ]; then
  generate_database_yml

  echo "This is your database-config file: "
  cat /usr/local/redmine/config/database.yml
fi

if [ -n "$ENABLE_GIT_USER" ]; then
  enable_git_user
fi

# Run migration and exit.
if [ -n "$RUN_MIGRATION" ]; then
  run_migration
  exit 0
fi

# Run bundle install.
if [ -n "$INSTALL_BUNDLE" ]; then
  install_bundle
fi


# Normal startup process
generate_secret
launch_apache &
tail -f /var/log/apache2/*.log /usr/local/redmine/log/production.log
