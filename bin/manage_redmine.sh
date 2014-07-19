#!/bin/bash

# A script that launches a shell inside a Redmine session.
# This is useful for running database upgrades etc.
sudo docker run --rm \
  -v /var/run/mysqld/mysqld.sock:/tmp/mysql.sock \
  -v /usr/local/redmine-store/plugins:/usr/local/redmine/plugins \
  -v /usr/local/redmine-store/config/database.yml:/usr/local/redmine/config/database.yml:ro \
  -v /usr/local/redmine-store/config/configuration.yml:/usr/local/redmine/config/configuration.yml:ro \
  -v /usr/local/redmine-store/files:/usr/local/redmine/files \
  -e "RUN_MIGRATION=True" \
  -e "INSTALL_BUNDLE=True" \
  -i -t vpetersson/redmine /bin/bash
