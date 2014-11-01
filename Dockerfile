# Dockerized Redmine
#
# VERSION               0.0.1

FROM ubuntu:14.04
MAINTAINER Viktor Petersson <vpetersson@wireload.net>

# Make sure we're up to date
RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get install -y wget ruby ruby-dev build-essential imagemagick libmagickwand-dev libmysqlclient-dev apache2 apt-transport-https ca-certificates git-core

# Install Phusion Passenger
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list
RUN apt-get update
RUN apt-get install -y libapache2-mod-passenger

# Fetch the latest redmine repo (and delete `.git`) to save space)
ENV BRANCH 2.5-stable
RUN cd /usr/local && git clone https://github.com/redmine/redmine.git && cd redmine && git checkout $BRANCH && rm -rf .git

RUN touch /usr/local/redmine/log/production.log
WORKDIR /usr/local/redmine

# Install dependencies
RUN gem install bundler
RUN gem install mysql2
RUN bundle install --without development test

# Add files and clean up unnecessary files
ADD include_files/redmine_apache.conf /etc/apache2/redmine_apache.conf
ADD include_files/start.sh /start.sh

# Free up some disk space
RUN apt-get clean

EXPOSE 3000

CMD /start.sh
