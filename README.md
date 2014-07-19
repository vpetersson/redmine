# Dockerized Redmine

** WORK IN PROGRESS **

Unless you're a Rails-shop, chances are you don't want to pollute your server with a ton of Rails related dependencies caused by Redmine. Yet, [Redmine](http://www.redmine.org/) is a great too, so you want to use it.

One solution to this is to put Redmine in a [Docker](http://docker.io) container, and get the best of both worlds.

This container is a full-blown Redmine installation running on Ubuntu 14.04 (with Apache and Passenger).

## Fetching the container

To fetch this pre-installed Redmine container, simply run:

    $ docker pull vpetersson/redmine

## Preparing the host

Given that Docker containers are designed to be somewhat ephimeral, we don't want to store our persistant data inside the container. All we want is Redmine and the required dependencies. To resolve this, we will utilize Docker's 'Volumes' support, and mount the relevant files outside of Docker. This also allows us to easily upgrade between Redmine version (i.e. upgrading the Docker container) without losing any data.

In order to do this, we will need to create the following folders on your host server:

 * /usr/local/redmine-store/config
 * /usr/local/redmine-store/files
 * /usr/local/redmine-store/plugins (optional)

You may place these folders somewhere else, just make sure you update the corresponding paths below.

With that done, you now need to create two files. First, we need to create the `/usr/local/redmine-store/config/configuration.yml` file. You'll find plenty of examples [here](http://www.redmine.org/projects/redmine/repository/entry/branches/2.5-stable/config/configuration.yml.example). A real simple config file would only include the email configuration, and look something like this:

    production:
      email_delivery:
        delivery_method: :smtp
        smtp_settings:
          enable_starttls_auto: true
          address: "smtp.gmail.com"
          port: 587
          domain: "smtp.gmail.com" # 'your.domain.com' for GoogleApps
          authentication: :plain
          user_name: "your_email@gmail.com"
          password: "your_password"

Next, we need to configure the database connection. This is a bit trickier. While Redmine could use multiple back-ends, this container is configured ot use MySQL.

Since we don't run the database in the same Docker container, we need to connect over TCP/IP, or alternatively use a socket and mount that into the container.

One 'gotcha' here is that you cannot connect to '127.0.0.1' on the host server within a Docker container. Hence, if you're running MySQL on the same server, the easiest way is to use a socket.

If you're using a socket, then you're `/usr/local/redmine-store/config/database.yml` file would look something like this:

    production:
      adapter: mysql2
      database: redmine
      socket: /tmp/mysql.sock
      username: redmine
      password: something
      encoding: utf8

When using a socket, you also need to make sure to pass on the following to your Docker run command `-v /path/to/mysql.sock:/tmp/mysql.sock`.

If you're on the other hand connecting to a database on a different host, it would look look something like this (replace a.b.c.d with the IP of your server).

    production:
      adapter: mysql2
      database: redmine
      host: a.b.c.d
      port: 3306
      username: redmine
      password: something
      encoding: utf8

## Running the container

On the first run, you need to run the container with the `RUN_MIGRATION=True` environment variable. This will trigger the migration to run

    $ docker run --rm \
      -v /usr/local/redmine-store/config/database.yml:/usr/local/redmine/config/database.yml:ro \
      -v /usr/local/redmine-store/config/configuration.yml:/usr/local/redmine/config/configuration.yml:ro \
      -v /usr/local/redmine-store/files:/usr/local/redmine/files \
      -e "RUN_MIGRATION=True" \
      -i -t vpetersson/redmine

Assuming the migration went well, you can now start the instance using:

    $ docker run -d \
      -v /usr/local/redmine-store/config/database.yml:/usr/local/redmine/config/database.yml:ro \
      -v /usr/local/redmine-store/config/configuration.yml:/usr/local/redmine/config/configuration.yml:ro \
      -v /usr/local/redmine-store/files:/usr/local/redmine/files \
      -p 3000:3000 \
      --name redmine \
      -i -t vpetersson/redmine

You should now be able to connect to redmine on `0.0.0.0:3000` on your host server. Since no SSL is used here, it is recommended that you use something like Nginx with SSL as a reverse proxy in front of Redmine.

### Optional variables

 * -e "ENABLE_GIT_USER=True"

Setting this variable will create a git-user and group in the VM. This is useful if you want to be able to read from a git repository on the host. The GID and UID is '3002'.

 * -e "RUN_MIGRATION=True"

This variable will trigger a migration to be run. This is useful for either the first time you start Redmine on an empty database, or if you've upgraded to a new version. Using this option for every start isn't recommended.

 * -e "INSTALL_BUNDLE=True"

Runs Bundle install before launching Redmine. This is useful for some plugins.

## FAQ

### How do I run plugins?

First, make sure you have a plugin folder on the host, such as `/usr/local/redmine-store/plugins`.

Next, mount the volume by adding:

    -v /usr/local/redmine-store/plugins:/usr/local/redmine/plugins

You should now be able to install plugins into this folder on the host.

If your plugin requires additional rependencies, make sure to add `-e "INSTALL_BUNDLE=True"`.
