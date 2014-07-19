#!/bin/bash

function prepare_fs {
  echo "Creating necessary folders and setting permission..."
  mkdir -p /usr/local/redmine/{log,files,tmp,tmp/pdf,public/plugin_assets}
  chown -R www-data:www-data /usr/local/redmine*
  chmod -R 0755 /usr/local/redmine/{files,tmp,tmp/pdf,public/plugin_assets}
}

# Only run the migration if the environment
# variable 'RUN_MIGRATION' is set.
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

# Install the bundle. This is useful if you install
# a new plugin that adds new dependencies.
function install_bundle {
  echo "Installing bundle..."
  cd /usr/local/redmine
  RAILS_ENV=production bundle install --without development test
}

function launch_apache {
  echo "Launching Apache..."
  apache2ctl \
    -f /etc/apache2/redmine_apache.conf \
    -D FOREGROUND
}

# If 'ENABLE_GIT_USER' is set, create a `git` user
# and add www-data to the user. This is useful if you
# need to access a git repository on the host server.
function enable_git_user {
  echo "Adding 'git' user and group..."
  groupadd -g 3002 git
  useradd -u 3002 -g git git
  usermod -a -G git www-data
}


# Make sure the permissions are properly set.
prepare_fs

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
