#!/bin/bash

function run_upgrade {
  echo "Running Redmine upgrade scripts..."
  RAILS_ENV=production
  cd /usr/local/redmine
  rake db:migrate
  rake generate_secret_token
}

function launch_apache {
  apache2 \
    -f /etc/apache2/redmine_apache.conf \
    -D FOREGROUND
}


# Only run the upgrade if the environment
# variable 'RUN_UPGRADE' is set.
if [ -z $RUN_UPGRADE ]; then
  run_upgrade
else
  launch_apache
fi
