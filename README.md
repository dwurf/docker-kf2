docker-kf2
==========

Dockerfile for running a Killing Floor 2 server under 
[wine](https://www.winehq.org)

Requirements
------------

2GB RAM and 10GB free disk space are essential. SSD recommended, otherwise map
changes will take a long time. Disk space requirements will keep going up as 
updates are released.

Simple start
------------

    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/kf2 \
        dwurf/docker-kf2:latest

Variables
---------

`KF_MAP` (default: `KF-BioticsLab`)

Starting map when the server is first loaded

`KF_DIFFICULTY` (default: `0`)

Game difficulty. 

* 0 - normal
* 1 - hard
* 2 - suicidal
* 3 - hell on earth

`KF_ADMIN_PASS` (default: `secret`)

Used for web console and in-game admin logins

`KF_GAME_PASS` (default: `''`)

Setting this creates a private server

`KF_GAME_LENGTH` (default: `1`)

* 0 - 4 waves
* 1 - 7 waves
* 2 - 10 waves

`KF_SERVER_NAME` (default: `Killing Floor 2 Server`)

Name that appears in the server browser

`KF_ENABLE_WEB` (default: `false`)

Set to `true` to enable the web console. You should probably also change the
default admin password
Access the web console on port 8080, the username is `admin`, the password is
set to `KF_ADMIN_PASS` (default: `secret`)

Building the image
------------------

    docker build .

