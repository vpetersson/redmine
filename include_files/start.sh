#!/bin/bash

function prepare_fs {
  mkdir -p /usr/local/redmine/{log,files,tmp,tmp/pdf,public/plugin_assets}
  chown -R www-data:www-data /usr/local/redmine*
  chmod -R 0755 /usr/local/redmine/{files,tmp,tmp/pdf,public/plugin_assets}
}

function run_migration {
  echo "Running Redmine migration scripts..."
  cd /usr/local/redmine
  RAILS_ENV=production rake db:migrate
}

function generate_secret {
  echo "Generating secret..."
  cd /usr/local/redmine
  RAILS_ENV=production rake generate_secret_token
}

function launch_apache {
  apache2ctl \
    -f /etc/apache2/redmine_apache.conf \
    -D FOREGROUND
}

function enable_git_user {
  groupadd -g 3002 git
  useradd -u 3002 -g git git
  usermod -a -G git www-data
}


# Make sure the permissions are properly set.
prepare_fs

# If 'ENABLE_GIT_USER' is set, create a `git` user
# and add www-data to the user. This is useful if you
# need to access a git repository on the host server.
if [ -n "$ENABLE_GIT_USER" ]; then
  enable_git_user
fi

# Only run the migration if the environment
# variable 'RUN_MIGRATION' is set.
if [ -n "$RUN_MIGRATION" ]; then
  run_migration
else
  generate_secret

  echo "Launching Apache..."
  launch_apache &
  tail -f /var/log/apache2/*.log /usr/local/redmine/log/production.log
fi
