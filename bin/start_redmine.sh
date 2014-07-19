#!/bin/bash

# An example on how to run Redmine
sudo docker run -d \
  -v /var/run/mysqld/mysqld.sock:/tmp/mysql.sock \
  -v /usr/local/redmine-store/config/database.yml:/usr/local/redmine/config/database.yml:ro \
  -v /usr/local/redmine-store/config/configuration.yml:/usr/local/redmine/config/configuration.yml:ro \
  -v /usr/local/redmine-store/files:/usr/local/redmine/files \
  -v /usr/local/redmine-store/plugins:/usr/local/redmine/plugins \
  -v /usr/local/redmine-store/themes:/usr/local/redmine/public/themes \
  -p 3030:3000 \
  #-v /usr/local/git/repositories/:/usr/local/git/repositories/:ro \
  #-e "ENABLE_GIT_USER=True" \
  --name redmine \
  -i -t vpetersson/redmine
