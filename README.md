# Dockerized Redmine

** WORK IN PROGRESS **

Unless you're a Rails-shop, chances are you don't want to pollute your server with a to of Rails related dependencies caused by Redmine. Yet, Redmine is a great too, so you want to use it.

The solution is to put Redmine in a Docker container, and get the best of both worlds.

This container is a full-blown Redmine installation running on Ubuntu 14.04 (with Apache and Passenger).

Given that Docker containers are designed to be somewhat ephimeral, we don't want to store our persistant data inside the container. All we want is Redmine and the required dependencies. To resolve this, we will utilize Docker's 'Volumes' support, and mount the relevant files outside of Docker. This also allows us to easily upgrade between Redmine version (i.e. upgrading the Docker container) without losing any data.

In order to do this, we will need to create the following folders on your host server:

 * /usr/local/redmine-store/config
 * /usr/local/redmine-store/files

You may place these folders somewhere else, just make sure you update the corresponding paths below.



## Connecting to MySQL

* Socket

    adapter: mysql2
    host: localhost
    username: root
    password: xxxx
    database: xxxx
    socket: /tmp/mysql.sock


* TCP/IP


