#!/bin/bash

RAILS_ENV=production

function set_permission {
  mkdir -p /usr/local/redmine/{log,files,tmp,tmp/pdf,public/plugin_assets}
  chown -R www-data:www-data /usr/local/redmine*
  chmod -R 0755 /usr/local/redmine/{files,tmp,tmp/pdf,public/plugin_assets}
}

function run_migration {
  echo "Running Redmine migration scripts..."
  cd /usr/local/redmine
  rake db:migrate
}

function generate_secret {
  echo "Generating secdet..."
  cd /usr/local/redmine
  rake generate_secret_token
}

function launch_apache {
  apache2ctl \
    -f /etc/apache2/redmine_apache.conf \
    -D FOREGROUND
}

# Make sure the permissions are properly set.
set_permission

# Only run the migration if the environment
# variable 'RUN_MIGRATION' is set.
if [ -n "$RUN_UPGRADE" ]; then
  run_migration
else
  generate_secret

  echo "Launching Apache..."
  launch_apache &
  tail -f /var/log/apache2/*.log /usr/local/redmine/log/production.log
fi
